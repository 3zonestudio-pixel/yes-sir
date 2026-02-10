import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/mission.dart';
import 'database_helper.dart';
import 'token_manager.dart';

/// Enhanced AI Service - LongCat AI
/// Powered by LongCat AI API (https://longcat.chat/platform/docs)
/// Features: Smart prioritization, task breakdown, proactive suggestions,
/// templates, gamification, productivity insights.
class AIService {
  final TokenManager tokenManager;
  final DatabaseHelper _db = DatabaseHelper.instance;

  static const String _apiUrl =
      'https://api.longcat.chat/openai/v1/chat/completions';
  static const String _apiKey = 'ak_2q07SX7uX2sx5u28BU8mO34Y7w76c';
  static const String _model = 'LongCat-Flash-Chat';

  static const String _systemPrompt = '''
You are an AI productivity advisor in the "Yes Sir" app. 
You help users plan, organize, and accomplish their missions (tasks).

Your personality:
- Friendly but efficient — like a supportive coach
- Use clear, actionable language
- Be motivating and positive
- Address the user warmly, sometimes saying "Commander" as a fun app reference
- Keep a professional yet approachable tone

Your capabilities:
1. **Task Management**: Create missions, set priorities, organize tasks
2. **Smart Planning**: Plan daily/weekly schedules based on priorities and deadlines
3. **Task Breakdown**: Split complex tasks into manageable sub-steps
4. **Prioritization**: Rank tasks by urgency, importance, and deadlines
5. **Templates**: Suggest pre-built mission templates for common workflows
6. **Productivity Tips**: Offer insights based on work patterns
7. **Motivation**: Provide encouragement and celebrate wins
8. **Reminders**: Help set smart reminders before deadlines

Response style:
- Use bullet points and structure for clarity
- Keep responses concise but thorough
- Use emojis sparingly for visual warmth (✅, 📋, 🎯, 💡, 🔥)
- Give actionable advice, not just information
- When creating tasks, clearly state the title

Priority levels: CRITICAL > HIGH > MEDIUM > LOW
Task statuses: Pending, In Progress, Completed

When asked to break down a task, provide 3-7 clear sub-steps.
When planning a day, organize by time blocks and priority.
When giving templates, provide ready-to-use mission structures.
''';

  AIService({required this.tokenManager});

  /// Process a command with enhanced AI capabilities
  Future<AIResponse> processCommand(String command) async {
    if (!tokenManager.hasTokens) {
      return AIResponse(
        message:
            "You've used all your tokens for today! They'll reset at midnight. See you tomorrow! 🌙",
        tokensUsed: 0,
        actions: [],
      );
    }

    // Save user message
    await _db.insertChatMessage(ChatMessage(
      role: ChatRole.commander,
      content: command,
      tokensUsed: 0,
    ));

    // Build context
    final recentMessages = await _db.getRecentChatMessages(limit: 8);
    final missionContext = await _buildMissionContext();

    String response;
    int tokensUsed;
    List<AIAction> actions = [];

    try {
      final apiResult =
          await _callLongCatAPI(command, recentMessages, missionContext);
      response = apiResult['message'] as String;
      tokensUsed = apiResult['tokensUsed'] as int;
    } catch (e) {
      // Fallback to enhanced offline mode
      final offlineResult = await _handleOffline(command);
      response = offlineResult;
      tokensUsed = tokenManager.estimateTokens(response);
    }

    // Consume tokens
    final consumed = await tokenManager.consumeTokens(tokensUsed);
    if (!consumed) {
      return AIResponse(
        message:
            "Not enough tokens for this request. ${tokenManager.tokensRemaining} tokens remaining today.",
        tokensUsed: 0,
        actions: [],
      );
    }

    // Parse actions
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

  /// Call the LongCat AI API
  Future<Map<String, dynamic>> _callLongCatAPI(
    String command,
    List<ChatMessage> history,
    String missionContext,
  ) async {
    final messages = <Map<String, String>>[];

    messages.add({
      'role': 'system',
      'content': '$_systemPrompt\n\nCurrent workspace:\n$missionContext',
    });

    for (var msg in history) {
      messages.add({
        'role': msg.role == ChatRole.commander ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

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
            'AI is under heavy load right now. Please try again in a moment! 😊',
        'tokensUsed': 10,
      };
    } else {
      throw Exception('API error: ${httpResponse.statusCode}');
    }
  }

  /// Build mission context for AI
  Future<String> _buildMissionContext() async {
    final stats = await _db.getMissionStats();
    final pending = await _db.getMissionsByStatus(MissionStatus.pending);
    final inProgress = await _db.getMissionsByStatus(MissionStatus.inProgress);

    String context = 'Missions: ${stats['total'] ?? 0} total, '
        '${stats['completed'] ?? 0} done, '
        '${stats['inProgress'] ?? 0} active, '
        '${stats['pending'] ?? 0} pending\n'
        'Tokens: ${tokenManager.tokensRemaining}/${tokenManager.tokenLimit} remaining\n';

    if (inProgress.isNotEmpty) {
      context += 'Active: ';
      context += inProgress.take(5).map((m) => '[${m.priorityLabel}] ${m.title}').join(', ');
      context += '\n';
    }
    if (pending.isNotEmpty) {
      context += 'Pending: ';
      context += pending.take(5).map((m) {
        final due = m.dueDate != null ? ' (due ${m.dueDate!.day}/${m.dueDate!.month})' : '';
        return '[${m.priorityLabel}] ${m.title}$due';
      }).join(', ');
    }
    return context;
  }

  /// Parse actions from command
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

  /// Enhanced offline fallback with all features
  Future<String> _handleOffline(String command) async {
    final lowerCommand = command.toLowerCase().trim();

    if (_isGreeting(lowerCommand)) {
      return _generateGreeting();
    } else if (_isStatusRequest(lowerCommand)) {
      return await _generateStatusReport();
    } else if (_isTaskCreation(lowerCommand)) {
      final parsed = _parseTaskFromCommand(command);
      return "✅ Mission created: \"${parsed['title']}\"\nPriority: ${(parsed['priority'] as MissionPriority).name.toUpperCase()}\n\nReady for your next order!";
    } else if (_isPlanRequest(lowerCommand)) {
      return await _generateDailyPlan();
    } else if (_isBreakdownRequest(lowerCommand)) {
      return _generateBreakdownSuggestion(command);
    } else if (_isTemplateRequest(lowerCommand)) {
      return _generateTemplates();
    } else if (_isPrioritizeRequest(lowerCommand)) {
      return await _generatePrioritization();
    } else if (_isTipsRequest(lowerCommand)) {
      return _generateProductivityTips();
    } else if (_isHelpRequest(lowerCommand)) {
      return _generateHelp();
    } else if (_isMotivation(lowerCommand)) {
      return _generateMotivation();
    }
    return "I'm currently in offline mode, but I can still help with basic commands! Try:\n\n📋 \"Plan my day\"\n🧩 \"Break down [task]\"\n📊 \"Status report\"\n📝 \"Show templates\"\n💡 \"Give me tips\"";
  }

  // ===== INTENT DETECTION =====

  bool _isGreeting(String cmd) {
    final greetings = ['hello', 'hi', 'hey', 'yo', 'sup', 'good morning', 'good evening', 'good afternoon'];
    return greetings.any((g) => cmd.startsWith(g) || cmd == g);
  }

  bool _isStatusRequest(String cmd) {
    return cmd.contains('status') || cmd.contains('report') ||
        cmd.contains('how am i') || cmd.contains('progress') || cmd.contains('summary');
  }

  bool _isTaskCreation(String cmd) {
    return cmd.startsWith('add ') || cmd.startsWith('create ') ||
        cmd.startsWith('new ') || cmd.startsWith('make ') ||
        cmd.contains('add task') || cmd.contains('add mission') ||
        cmd.contains('create task') || cmd.contains('create mission');
  }

  bool _isPlanRequest(String cmd) {
    return cmd.contains('plan') || cmd.contains('schedule') ||
        cmd.contains('organize my day') || cmd.contains('what should i do');
  }

  bool _isBreakdownRequest(String cmd) {
    return cmd.contains('break down') || cmd.contains('breakdown') ||
        cmd.contains('split') || cmd.contains('break into') ||
        cmd.contains('sub-task') || cmd.contains('subtask') ||
        cmd.contains('smaller step');
  }

  bool _isTemplateRequest(String cmd) {
    return cmd.contains('template') || cmd.contains('preset') ||
        cmd.contains('workflow') || cmd.contains('routine');
  }

  bool _isReminderRequest(String cmd) {
    return cmd.contains('remind') || cmd.contains('alarm') || cmd.contains('notify');
  }

  bool _isPrioritizeRequest(String cmd) {
    return cmd.contains('prioriti') || cmd.contains('rank') ||
        cmd.contains('sort') || cmd.contains('important');
  }

  bool _isTipsRequest(String cmd) {
    return cmd.contains('tip') || cmd.contains('advice') ||
        cmd.contains('productivity') || cmd.contains('suggestion') ||
        cmd.contains('recommend');
  }

  bool _isHelpRequest(String cmd) {
    return cmd.contains('help') || cmd.contains('what can you') || cmd.contains('commands');
  }

  bool _isMotivation(String cmd) {
    return cmd.contains('motivat') || cmd.contains('inspire') || cmd.contains('encourage');
  }

  // ===== RESPONSE GENERATORS =====

  String _generateGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = "Good morning";
    } else if (hour < 17) {
      greeting = "Good afternoon";
    } else {
      greeting = "Good evening";
    }

    final greetings = [
      "$greeting! Ready to help you conquer today's missions 🎯",
      "$greeting, Commander! What's on the agenda today?",
      "$greeting! Let's make today productive. What can I help with?",
      "$greeting! Your AI advisor is ready. Fire away! 💪",
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
      return "You don't have any missions yet! Tap + to create your first one, or tell me what you're working on 🎯";
    }

    final completionRate = total > 0 ? ((completed / total) * 100).toStringAsFixed(0) : '0';

    return """📊 Your Progress Report

✅ Completed: $completed
🔄 Active: $inProgress
⏳ Pending: $pending
📈 Completion Rate: $completionRate%

${_getStatusComment(completed, pending, inProgress)}

${tokenManager.tokensRemaining} AI tokens remaining today.""";
  }

  String _getStatusComment(int completed, int pending, int inProgress) {
    if (pending == 0 && inProgress == 0) {
      return "🎉 Everything done! You're on fire!";
    } else if (completed > pending) {
      return "💪 Great momentum! Keep it up!";
    } else if (pending > completed * 2) {
      return "🎯 Focus on the high-priority items first — you've got this!";
    }
    return "📋 Steady progress! Take it one mission at a time.";
  }

  Future<String> _generateDailyPlan() async {
    final missions = await _db.getMissionsByStatus(MissionStatus.pending);
    final inProgress = await _db.getMissionsByStatus(MissionStatus.inProgress);

    if (missions.isEmpty && inProgress.isEmpty) {
      return "Your schedule is clear! 🌟\n\nThis is a great time to:\n• Plan your week\n• Set new goals\n• Review past accomplishments\n\nWant me to suggest some mission templates?";
    }

    String plan = "📋 Today's Game Plan\n\n";

    if (inProgress.isNotEmpty) {
      plan += "🔄 Continue These (in progress):\n";
      for (int i = 0; i < inProgress.length && i < 5; i++) {
        plan += "  ${i + 1}. ${inProgress[i].title} [${inProgress[i].priorityLabel}]\n";
      }
      plan += "\n";
    }

    if (missions.isNotEmpty) {
      missions.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      plan += "📌 Up Next (by priority):\n";
      for (int i = 0; i < missions.length && i < 10; i++) {
        final dueText = missions[i].dueDate != null
            ? ' — Due ${missions[i].dueDate!.day}/${missions[i].dueDate!.month}'
            : '';
        plan += "  ${i + 1}. ${missions[i].title} [${missions[i].priorityLabel}]$dueText\n";
      }
    }

    plan += "\n💡 Tip: Tackle critical & high priority items during your peak energy hours!";
    return plan;
  }

  Future<String> _generatePrioritization() async {
    final missions = await _db.getMissionsByStatus(MissionStatus.pending);

    if (missions.isEmpty) {
      return "No pending missions to prioritize! All clear ✅";
    }

    missions.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    String result = "🎯 Priority Ranking\n\n";

    final critical = missions.where((m) => m.priority == MissionPriority.critical).toList();
    final high = missions.where((m) => m.priority == MissionPriority.high).toList();
    final medium = missions.where((m) => m.priority == MissionPriority.medium).toList();
    final low = missions.where((m) => m.priority == MissionPriority.low).toList();

    if (critical.isNotEmpty) {
      result += "🔴 CRITICAL — Do these NOW:\n";
      for (var m in critical) result += "  • ${m.title}\n";
      result += "\n";
    }

    if (high.isNotEmpty) {
      result += "🟠 HIGH — Today's targets:\n";
      for (var m in high) result += "  • ${m.title}\n";
      result += "\n";
    }

    if (medium.isNotEmpty) {
      result += "🔵 MEDIUM — This week:\n";
      for (var m in medium) result += "  • ${m.title}\n";
      result += "\n";
    }

    if (low.isNotEmpty) {
      result += "🟢 LOW — When you have time:\n";
      for (var m in low) result += "  • ${m.title}\n";
    }

    return result;
  }

  String _generateBreakdownSuggestion(String command) {
    // Extract the task name from the command
    String task = command
        .replaceAll(RegExp(r'break\s*down', caseSensitive: false), '')
        .replaceAll(RegExp(r'split|into\s+steps?|smaller', caseSensitive: false), '')
        .replaceAll(RegExp(r'^\s*:?\s*'), '')
        .trim();

    if (task.isEmpty) {
      task = 'your task';
    }

    return """🧩 Breaking Down: "$task"

Here's a suggested breakdown:

1. 📋 Research & Planning
   Define scope and requirements

2. 🎯 Setup & Preparation
   Gather resources and tools needed

3. 🔨 Core Implementation
   Work on the main deliverable

4. ✅ Review & Test
   Verify quality and completeness

5. 📦 Finalize & Deliver
   Wrap up and mark complete

💡 Tip: Create each step as a sub-mission for better tracking!

Want me to create these as missions? Just say "create subtasks".""";
  }

  String _generateTemplates() {
    return """📝 Mission Templates

Choose a template to get started:

🏋️ **Morning Routine**
• Wake up & stretch (Low)
• Exercise 30min (Medium)
• Plan the day (High)
• Healthy breakfast (Low)

💻 **Work Sprint**
• Review priorities (High)
• Focus block: 2 hours (Critical)
• Check & respond to messages (Medium)
• Progress review (Medium)

📚 **Study Session**
• Review previous material (Medium)
• Learn new concepts (High)
• Practice exercises (High)
• Summary notes (Medium)

🏠 **Weekly Home Tasks**
• Grocery shopping (Medium)
• Clean common areas (Medium)
• Laundry (Low)
• Meal prep (Medium)

🚀 **Project Launch**
• Finalize requirements (Critical)
• Complete development (Critical)
• Testing & QA (High)
• Documentation (Medium)
• Deploy (Critical)

Tell me which template you want and I'll create the missions for you!""";
  }

  String _generateProductivityTips() {
    final tips = [
      """💡 Productivity Tips

1. **2-Minute Rule**: If a task takes less than 2 minutes, do it immediately
2. **Time Blocking**: Dedicate specific hours to specific types of work
3. **Eat the Frog**: Do your hardest/most important task first
4. **Pomodoro Technique**: Work 25 min, break 5 min, repeat
5. **Review & Reflect**: End each day reviewing what you accomplished

🎯 Start with the tip that resonates most with you!""",
      """💡 Focus & Energy Tips

1. **Peak Hours**: Schedule important work during your highest energy times
2. **Batch Similar Tasks**: Group emails, calls, and similar work together
3. **Minimize Context Switching**: Focus on one thing at a time
4. **Take Real Breaks**: Step away from your workspace
5. **Celebrate Small Wins**: Acknowledge each completed mission!

✨ Remember: Progress > Perfection""",
      """💡 Planning Tips

1. **Plan Tomorrow Tonight**: Spend 5 min each evening planning tomorrow
2. **3 Key Tasks**: Pick 3 most important tasks each day
3. **Weekly Review**: Review and adjust priorities every Sunday
4. **Buffer Time**: Leave 20% of your day unscheduled for unexpected tasks
5. **Say No**: Protect your time — not every request is urgent

📋 Shall I help you plan your day right now?""",
    ];
    return tips[Random().nextInt(tips.length)];
  }

  String _generateHelp() {
    return """🤖 What I Can Help With

📋 **Plan my day** — Get a prioritized daily schedule
➕ **Add [task]** — Create a new mission
📊 **Status report** — See your progress overview
🎯 **Prioritize my tasks** — Rank by importance
🧩 **Break down [task]** — Split into sub-steps
📝 **Show templates** — Ready-made mission templates
💡 **Give me tips** — Productivity advice
💪 **Motivate me** — Get some encouragement
⏰ **Remind me to [task]** — Set a reminder

Pro tips:
• Add priority: "Add urgent: Fix the bug"
• Be specific for better results
• Use templates for quick setup

${tokenManager.tokensRemaining} tokens remaining today ⚡""";
  }

  String _generateMotivation() {
    final quotes = [
      "You've got this! Every great achievement started with a single step. Take that step now 💪",
      "Discipline beats motivation every time. But hey, why not have both? Let's go! 🔥",
      "You've survived 100% of your toughest days. That's an undefeated record. Keep going! ⭐",
      "The best time to start was yesterday. The second best time is NOW. What's the first task? 🎯",
      "Pressure makes diamonds. Every challenge is shaping you into something amazing ✨",
      "Small progress is still progress. Don't compare your chapter 1 to someone's chapter 20 📚",
      "Success is the sum of small efforts repeated day after day. You're building something great! 🏗️",
    ];
    return quotes[Random().nextInt(quotes.length)];
  }

  // ===== PARSERS =====

  Map<String, dynamic> _parseTaskFromCommand(String command) {
    String title = command;
    MissionPriority priority = MissionPriority.medium;

    final prefixes = ['add ', 'create ', 'new ', 'make ', 'add task ', 'add mission ', 'create task ', 'create mission ', 'todo '];
    for (var prefix in prefixes) {
      if (title.toLowerCase().startsWith(prefix)) {
        title = title.substring(prefix.length);
        break;
      }
    }

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

    title = title.replaceAll(RegExp(r'^remind me to\s+', caseSensitive: false), '');
    title = title.replaceAll(RegExp(r'^remind me\s+', caseSensitive: false), '');

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

  /// Generate daily briefing for proactive suggestions
  Future<String> generateDailyBriefing() async {
    final stats = await _db.getMissionStats();
    final pending = await _db.getMissionsByStatus(MissionStatus.pending);
    final completed = stats['completed'] ?? 0;
    final total = stats['total'] ?? 0;

    // Find overdue/due-soon missions
    final now = DateTime.now();
    final dueSoon = pending.where((m) {
      if (m.dueDate == null) return false;
      return m.dueDate!.difference(now).inHours < 24 && m.dueDate!.isAfter(now);
    }).toList();

    final overdue = pending.where((m) {
      if (m.dueDate == null) return false;
      return m.dueDate!.isBefore(now);
    }).toList();

    String briefing = "☀️ Daily Briefing\n\n";

    if (overdue.isNotEmpty) {
      briefing += "⚠️ Overdue (${overdue.length}):\n";
      for (var m in overdue) {
        briefing += "  • ${m.title}\n";
      }
      briefing += "\n";
    }

    if (dueSoon.isNotEmpty) {
      briefing += "⏰ Due soon (${dueSoon.length}):\n";
      for (var m in dueSoon) {
        briefing += "  • ${m.title}\n";
      }
      briefing += "\n";
    }

    briefing += "📊 Overall: $completed/$total completed";
    if (total > 0) {
      briefing += " (${((completed / total) * 100).toStringAsFixed(0)}%)";
    }

    if (pending.isEmpty && overdue.isEmpty) {
      briefing += "\n\n🎉 Nothing pending — great job!";
    } else {
      briefing += "\n\n💡 Focus on the most important task first!";
    }

    return briefing;
  }

  /// Generate daily report
  Future<String> generateDailyReport() async {
    final stats = await _db.getMissionStats();
    final completed = stats['completed'] ?? 0;
    final pending = stats['pending'] ?? 0;

    return "$completed missions completed, $pending pending. ${tokenManager.tokensRemaining} AI tokens remaining.";
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
