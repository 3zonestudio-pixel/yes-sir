import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/mission.dart';
import 'database_helper.dart';
import 'token_manager.dart';

/// AI Service - Private LongCat
/// Powered by LongCat AI API (https://longcat.chat/platform/docs)
/// Falls back to offline mode when API is unavailable.
class AIService {
  final TokenManager tokenManager;
  final DatabaseHelper _db = DatabaseHelper.instance;

  static const String _apiUrl =
      'https://api.longcat.chat/openai/v1/chat/completions';
  static const String _apiKey = 'ak_2q07SX7uX2sx5u28BU8mO34Y7w76c';
  static const String _model = 'LongCat-Flash-Chat';

  static const String _systemPrompt = '''
You are Private LongCat, an AI military assistant in the "Yes Sir" app.
You serve the user as their Commander. You respond with military discipline, precision, and respect.

Your personality:
- Address the user as "Commander" or "Sir"
- Use military terminology (missions, objectives, operations, deploy, execute)
- Be efficient, clear, and motivating
- Start responses with "Yes Sir!" or "Sir," when appropriate
- Give structured, actionable responses
- Use military report format when giving status updates

Your capabilities:
- Convert natural language commands into tasks/missions
- Plan and prioritize the Commander's day
- Provide status reports on missions
- Break big missions into sub-missions
- Provide motivation and encouragement
- Set reminders

When the Commander asks to create a task or mission, respond confirming the mission and include the task title clearly.
When asked for a plan, organize tasks by priority (CRITICAL > HIGH > MEDIUM > LOW).
When asked for status, give a structured after-action report.

Keep responses concise but thorough. Use emojis sparingly for visual structure.
End key responses with "Standing by for orders." or similar military sign-off.
''';

  AIService({required this.tokenManager});

  /// Process a command from the Commander via LongCat AI API
  Future<AIResponse> processCommand(String command) async {
    if (!tokenManager.hasTokens) {
      return AIResponse(
        message:
            "Sir, daily token reserves depleted. Tokens reset at 0000 hours local time. Standing by.",
        tokensUsed: 0,
        actions: [],
      );
    }

    // Save commander message
    await _db.insertChatMessage(ChatMessage(
      role: ChatRole.commander,
      content: command,
      tokensUsed: 0,
    ));

    // Build context with recent chat history
    final recentMessages = await _db.getRecentChatMessages(limit: 8);
    final missionContext = await _buildMissionContext();

    String response;
    int tokensUsed;
    List<AIAction> actions = [];

    try {
      // Call LongCat AI API
      final apiResult =
          await _callLongCatAPI(command, recentMessages, missionContext);
      response = apiResult['message'] as String;
      tokensUsed = apiResult['tokensUsed'] as int;
    } catch (e) {
      // Fallback to offline mode
      final offlineResult = _handleOffline(command);
      response = await offlineResult['response'] as String;
      tokensUsed = tokenManager.estimateTokens(response);
    }

    // Consume tokens
    final consumed = await tokenManager.consumeTokens(tokensUsed);
    if (!consumed) {
      return AIResponse(
        message:
            "Sir, insufficient tokens for this operation. ${tokenManager.tokensRemaining} tokens remaining today.",
        tokensUsed: 0,
        actions: [],
      );
    }

    // Parse AI actions from the command (task creation, reminders)
    actions = _parseActionsFromCommand(command);

    // Save AI response
    await _db.insertChatMessage(ChatMessage(
      role: ChatRole.soldier,
      content: response,
      tokensUsed: tokensUsed,
    ));

    return AIResponse(
      message: response,
      tokensUsed: tokensUsed,
      actions: actions,
    );
  }

  /// Call the LongCat AI API (OpenAI-compatible format)
  Future<Map<String, dynamic>> _callLongCatAPI(
    String command,
    List<ChatMessage> history,
    String missionContext,
  ) async {
    final messages = <Map<String, String>>[];

    // System prompt with live mission context
    messages.add({
      'role': 'system',
      'content': '$_systemPrompt\n\nCurrent mission status:\n$missionContext',
    });

    // Add recent chat history for conversational context
    for (var msg in history) {
      messages.add({
        'role': msg.role == ChatRole.commander ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    // Current command
    messages.add({'role': 'user', 'content': command});

    final body = jsonEncode({
      'model': _model,
      'messages': messages,
      'max_tokens': 1000,
      'temperature': 0.7,
    });

    final httpResponse = await http
        .post(
          Uri.parse(_apiUrl),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (httpResponse.statusCode == 200) {
      final data = jsonDecode(httpResponse.body);
      final content =
          data['choices'][0]['message']['content'] as String? ?? '';
      final usage = data['usage'] as Map<String, dynamic>?;
      final totalTokens =
          usage?['total_tokens'] as int? ?? tokenManager.estimateTokens(content);

      return {'message': content, 'tokensUsed': totalTokens};
    } else if (httpResponse.statusCode == 429) {
      return {
        'message':
            'Sir, AI systems are under heavy load. Rate limit reached. Please retry shortly.',
        'tokensUsed': 10,
      };
    } else {
      throw Exception('API error: ${httpResponse.statusCode}');
    }
  }

  /// Build live mission context for the AI
  Future<String> _buildMissionContext() async {
    final stats = await _db.getMissionStats();
    final pending = await _db.getMissionsByStatus(MissionStatus.pending);
    final inProgress = await _db.getMissionsByStatus(MissionStatus.inProgress);

    String context = 'Total: ${stats['total'] ?? 0}, '
        'Completed: ${stats['completed'] ?? 0}, '
        'In Progress: ${stats['inProgress'] ?? 0}, '
        'Pending: ${stats['pending'] ?? 0}\n'
        'Tokens left today: ${tokenManager.tokensRemaining}/${tokenManager.tokenLimit}\n';

    if (inProgress.isNotEmpty) {
      context += 'Active missions: ';
      context += inProgress.take(5).map((m) => '[${m.priorityLabel}] ${m.title}').join(', ');
      context += '\n';
    }
    if (pending.isNotEmpty) {
      context += 'Pending missions: ';
      context += pending.take(5).map((m) => '[${m.priorityLabel}] ${m.title}').join(', ');
    }
    return context;
  }

  /// Parse task/reminder actions from user command
  List<AIAction> _parseActionsFromCommand(String command) {
    final actions = <AIAction>[];
    final lowerCmd = command.toLowerCase();

    if (_isTaskCreation(lowerCmd)) {
      final parsed = _parseTaskFromCommand(command);
      actions.add(AIAction(type: AIActionType.createMission, data: parsed));
    } else if (_isReminderRequest(lowerCmd)) {
      final parsed = _parseReminderFromCommand(command);
      actions.add(AIAction(type: AIActionType.createReminder, data: parsed));
    }
    return actions;
  }

  /// Offline fallback when API is unavailable
  Map<String, Future<String>> _handleOffline(String command) {
    final lowerCommand = command.toLowerCase().trim();

    if (_isGreeting(lowerCommand)) {
      return {'response': Future.value(_generateGreeting())};
    } else if (_isStatusRequest(lowerCommand)) {
      return {'response': _generateStatusReport()};
    } else if (_isTaskCreation(lowerCommand)) {
      final parsed = _parseTaskFromCommand(command);
      return {
        'response': Future.value(
            "Yes Sir! Mission created: \"${parsed['title']}\". (Offline mode)")
      };
    } else if (_isPlanRequest(lowerCommand)) {
      return {'response': _generateDailyPlan()};
    } else if (_isHelpRequest(lowerCommand)) {
      return {'response': Future.value(_generateHelp())};
    } else if (_isMotivation(lowerCommand)) {
      return {'response': Future.value(_generateMotivation())};
    }
    return {
      'response': Future.value(
          "Sir, AI comms temporarily offline. Basic commands still operational. Standing by for reconnection.")
    };
  }

  // ===== INTENT DETECTION =====

  bool _isGreeting(String cmd) {
    final greetings = ['hello', 'hi', 'hey', 'yo', 'sup', 'good morning', 'good evening', 'good afternoon'];
    return greetings.any((g) => cmd.startsWith(g) || cmd == g);
  }

  bool _isStatusRequest(String cmd) {
    return cmd.contains('status') ||
        cmd.contains('report') ||
        cmd.contains('how am i') ||
        cmd.contains('progress') ||
        cmd.contains('summary');
  }

  bool _isTaskCreation(String cmd) {
    return cmd.startsWith('add ') ||
        cmd.startsWith('create ') ||
        cmd.startsWith('new ') ||
        cmd.startsWith('make ') ||
        cmd.contains('add task') ||
        cmd.contains('add mission') ||
        cmd.contains('create task') ||
        cmd.contains('create mission');
  }

  bool _isPlanRequest(String cmd) {
    return cmd.contains('plan') ||
        cmd.contains('schedule') ||
        cmd.contains('organize my day') ||
        cmd.contains('what should i do');
  }

  bool _isReminderRequest(String cmd) {
    return cmd.contains('remind') || cmd.contains('alarm') || cmd.contains('notify');
  }

  bool _isPrioritizeRequest(String cmd) {
    return cmd.contains('prioriti') || cmd.contains('rank') || cmd.contains('sort') || cmd.contains('important');
  }

  bool _isHelpRequest(String cmd) {
    return cmd.contains('help') || cmd.contains('what can you') || cmd.contains('commands');
  }

  bool _isMotivation(String cmd) {
    return cmd.contains('motivat') || cmd.contains('inspire') || cmd.contains('encourage');
  }

  // ===== RESPONSE GENERATORS =====

  String _generateGreeting() {
    final greetings = [
      "Private LongCat reporting for duty, Commander! All systems operational. Awaiting orders.",
      "Sir, yes Sir! Ready to execute. What's the mission?",
      "Commander on deck! Private LongCat standing by. State your orders.",
      "Good to have you back, Commander. Your missions await. What's the play?",
    ];
    return greetings[Random().nextInt(greetings.length)];
  }

  Future<String> _generateStatusReport() async {
    final stats = await _db.getMissionStats();
    final total = stats['total'] ?? 0;
    final completed = stats['completed'] ?? 0;
    final pending = stats['pending'] ?? 0;
    final inProgress = stats['inProgress'] ?? 0;

    if (total == 0) {
      return "Sir, no missions in the system. Battlefield is clear. Ready to accept new orders.";
    }

    final completionRate = total > 0 ? ((completed / total) * 100).toStringAsFixed(0) : '0';

    return """📊 AFTER-ACTION REPORT, Commander:

═══════════════════════════
  Total Missions:    $total
  Completed:         $completed ✅
  In Progress:       $inProgress 🔄
  Pending:           $pending ⏳
  Completion Rate:   $completionRate%
═══════════════════════════

${_getStatusComment(completed, pending, inProgress)}

${tokenManager.tokensRemaining} tokens remaining today. Standing by for orders.""";
  }

  String _getStatusComment(int completed, int pending, int inProgress) {
    if (pending == 0 && inProgress == 0) {
      return "All clear, Commander! Every mission accomplished. Outstanding performance.";
    } else if (completed > pending) {
      return "Strong progress, Commander. Keep pushing forward.";
    } else if (pending > completed * 2) {
      return "Multiple missions pending, Sir. Recommend focusing on high-priority targets.";
    }
    return "Operations proceeding as planned, Commander.";
  }

  Future<String> _generateDailyPlan() async {
    final missions = await _db.getMissionsByStatus(MissionStatus.pending);
    final inProgress = await _db.getMissionsByStatus(MissionStatus.inProgress);

    if (missions.isEmpty && inProgress.isEmpty) {
      return "Sir, no pending missions detected. Your schedule is clear.\n\nRecommendation: Set new objectives to maintain momentum. A Commander without missions is a ship without sails.";
    }

    String plan = "🗺️ DAILY MISSION PLAN, Commander:\n\n";

    if (inProgress.isNotEmpty) {
      plan += "▶ ACTIVE MISSIONS (Continue these first):\n";
      for (int i = 0; i < inProgress.length && i < 5; i++) {
        plan += "  ${i + 1}. [${inProgress[i].priorityLabel}] ${inProgress[i].title}\n";
      }
      plan += "\n";
    }

    if (missions.isNotEmpty) {
      // Sort by priority
      missions.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      plan += "📋 PENDING MISSIONS (Sorted by priority):\n";
      for (int i = 0; i < missions.length && i < 10; i++) {
        plan += "  ${i + 1}. [${missions[i].priorityLabel}] ${missions[i].title}\n";
      }
    }

    plan += "\nRecommendation: Tackle CRITICAL and HIGH priority missions first. Report back when complete.";
    return plan;
  }

  Future<String> _generatePrioritization() async {
    final missions = await _db.getMissionsByStatus(MissionStatus.pending);

    if (missions.isEmpty) {
      return "Sir, no pending missions to prioritize. All clear.";
    }

    missions.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    String result = "⚡ PRIORITY ASSESSMENT, Commander:\n\n";

    final critical = missions.where((m) => m.priority == MissionPriority.critical).toList();
    final high = missions.where((m) => m.priority == MissionPriority.high).toList();
    final medium = missions.where((m) => m.priority == MissionPriority.medium).toList();
    final low = missions.where((m) => m.priority == MissionPriority.low).toList();

    if (critical.isNotEmpty) {
      result += "🔴 CRITICAL (Execute immediately):\n";
      for (var m in critical) {
        result += "  • ${m.title}\n";
      }
      result += "\n";
    }

    if (high.isNotEmpty) {
      result += "🟠 HIGH (Execute today):\n";
      for (var m in high) {
        result += "  • ${m.title}\n";
      }
      result += "\n";
    }

    if (medium.isNotEmpty) {
      result += "🟡 MEDIUM (Schedule this week):\n";
      for (var m in medium) {
        result += "  • ${m.title}\n";
      }
      result += "\n";
    }

    if (low.isNotEmpty) {
      result += "🟢 LOW (When time allows):\n";
      for (var m in low) {
        result += "  • ${m.title}\n";
      }
    }

    return result;
  }

  String _generateHelp() {
    return """📖 COMMAND MANUAL, Commander:

I respond to the following orders:

🔹 "Plan my day" — Get a prioritized daily plan
🔹 "Add [task]" — Create a new mission
🔹 "Status report" — See your mission stats
🔹 "Remind me to [task] at [time]" — Set a reminder
🔹 "Prioritize my tasks" — Rank missions by importance
🔹 "Motivate me" — Get a boost from Private LongCat

Pro tips:
• Be specific with orders for best results
• Mention priority: "Add urgent: Fix the bug"
• I learn from your patterns over time

Tokens remaining today: ${tokenManager.tokensRemaining}
Private LongCat, at your service! 🫡""";
  }

  String _generateMotivation() {
    final quotes = [
      "Commander, every great victory starts with a single order. You've got this. Move out! 💪",
      "Discipline is doing what needs to be done, even when you don't feel like it. You're built for this, Sir.",
      "The mission doesn't care about your mood. But I do. Let's crush it together, Commander! 🔥",
      "A true Commander doesn't wait for the perfect moment — they create it. What's the next move?",
      "Sir, you've survived 100% of your hardest days. That's an undefeated record. Keep going!",
      "Pressure makes diamonds, Commander. Every challenge is shaping you. Now let's execute! ⚡",
    ];
    return quotes[Random().nextInt(quotes.length)];
  }

  // ===== PARSERS =====

  Map<String, dynamic> _parseTaskFromCommand(String command) {
    String title = command;
    MissionPriority priority = MissionPriority.medium;

    // Remove action words
    final prefixes = ['add ', 'create ', 'new ', 'make ', 'add task ', 'add mission ', 'create task ', 'create mission ', 'todo '];
    for (var prefix in prefixes) {
      if (title.toLowerCase().startsWith(prefix)) {
        title = title.substring(prefix.length);
        break;
      }
    }

    // Detect priority keywords
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('urgent') || lowerTitle.contains('critical') || lowerTitle.contains('asap')) {
      priority = MissionPriority.critical;
      title = title.replaceAll(RegExp(r'\b(urgent|critical|asap):?\s*', caseSensitive: false), '');
    } else if (lowerTitle.contains('important') || lowerTitle.contains('high')) {
      priority = MissionPriority.high;
      title = title.replaceAll(RegExp(r'\b(important|high priority):?\s*', caseSensitive: false), '');
    } else if (lowerTitle.contains('low') || lowerTitle.contains('minor')) {
      priority = MissionPriority.low;
      title = title.replaceAll(RegExp(r'\b(low priority|minor):?\s*', caseSensitive: false), '');
    }

    title = title.trim();
    if (title.isEmpty) title = command;

    return {
      'title': title[0].toUpperCase() + title.substring(1),
      'priority': priority,
    };
  }

  Map<String, dynamic> _parseReminderFromCommand(String command) {
    String title = command;
    DateTime? reminderTime;

    // Remove prefix
    title = title.replaceAll(RegExp(r'^remind me to\s+', caseSensitive: false), '');
    title = title.replaceAll(RegExp(r'^remind me\s+', caseSensitive: false), '');

    // Try to extract time
    final timeRegex = RegExp(r'at (\d{1,2})\s*(am|pm|AM|PM)?', caseSensitive: false);
    final match = timeRegex.firstMatch(title);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final period = match.group(2)?.toLowerCase();
      if (period == 'pm' && hour < 12) hour += 12;
      if (period == 'am' && hour == 12) hour = 0;

      final now = DateTime.now();
      reminderTime = DateTime(now.year, now.month, now.day, hour);
      if (reminderTime.isBefore(now)) {
        reminderTime = reminderTime.add(const Duration(days: 1));
      }

      title = title.replaceAll(match.group(0)!, '').trim();
    }

    title = title.trim();
    if (title.isEmpty) title = command;

    return {
      'title': title[0].toUpperCase() + title.substring(1),
      'dueDate': reminderTime ?? DateTime.now().add(const Duration(hours: 1)),
      'priority': MissionPriority.high,
    };
  }

  /// Generate daily commander report
  Future<String> generateDailyReport() async {
    final stats = await _db.getMissionStats();
    final completed = stats['completed'] ?? 0;
    final pending = stats['pending'] ?? 0;

    return "Yes Sir. $completed missions completed. $pending pending. ${tokenManager.tokensRemaining} AI tokens remaining today.";
  }
}

// ===== RESPONSE MODELS =====

class AIResponse {
  final String message;
  final int tokensUsed;
  final List<AIAction> actions;

  AIResponse({
    required this.message,
    required this.tokensUsed,
    required this.actions,
  });
}

enum AIActionType {
  createMission,
  createReminder,
  updateMission,
  deleteMission,
}

class AIAction {
  final AIActionType type;
  final Map<String, dynamic> data;

  AIAction({required this.type, required this.data});
}
