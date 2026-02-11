import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mission.dart';
import '../models/chat_message.dart';
import '../models/token_usage.dart';

/// Web implementation using in-memory storage with SharedPreferences persistence.
class PlatformDatabase {
  final List<Mission> _missions = [];
  final List<ChatMessage> _chatMessages = [];
  final Map<String, TokenUsage> _tokenUsage = {};
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    // Load missions
    final missionsJson = _prefs?.getString('db_missions');
    if (missionsJson != null) {
      final list = jsonDecode(missionsJson) as List;
      _missions.clear();
      for (var map in list) {
        _missions.add(Mission.fromMap(Map<String, dynamic>.from(map)));
      }
    }

    // Load chat messages
    final chatJson = _prefs?.getString('db_chat');
    if (chatJson != null) {
      final list = jsonDecode(chatJson) as List;
      _chatMessages.clear();
      for (var map in list) {
        _chatMessages.add(ChatMessage.fromMap(Map<String, dynamic>.from(map)));
      }
    }

    // Load token usage
    final tokenJson = _prefs?.getString('db_tokens');
    if (tokenJson != null) {
      final map = jsonDecode(tokenJson) as Map<String, dynamic>;
      _tokenUsage.clear();
      map.forEach((key, value) {
        _tokenUsage[key] =
            TokenUsage.fromMap(Map<String, dynamic>.from(value));
      });
    }
  }

  Future<void> _saveMissions() async {
    final json = jsonEncode(_missions.map((m) => m.toMap()).toList());
    await _prefs?.setString('db_missions', json);
  }

  Future<void> _saveChat() async {
    final json = jsonEncode(_chatMessages.map((m) => m.toMap()).toList());
    await _prefs?.setString('db_chat', json);
  }

  Future<void> _saveTokens() async {
    final map = <String, dynamic>{};
    _tokenUsage.forEach((key, value) {
      map[key] = value.toMap();
    });
    await _prefs?.setString('db_tokens', jsonEncode(map));
  }

  // ===== MISSIONS =====

  Future<int> insertMission(Mission mission) async {
    final idx = _missions.indexWhere((m) => m.id == mission.id);
    if (idx >= 0) {
      _missions[idx] = mission;
    } else {
      _missions.add(mission);
    }
    await _saveMissions();
    return 1;
  }

  Future<List<Mission>> getAllMissions() async {
    final sorted = List<Mission>.from(_missions);
    sorted.sort((a, b) {
      final cmp = a.orderIndex.compareTo(b.orderIndex);
      if (cmp != 0) return cmp;
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  Future<List<Mission>> getTopLevelMissions() async {
    final filtered =
        _missions.where((m) => m.parentId == null).toList();
    filtered.sort((a, b) {
      final cmp = a.orderIndex.compareTo(b.orderIndex);
      if (cmp != 0) return cmp;
      return b.createdAt.compareTo(a.createdAt);
    });
    return filtered;
  }

  Future<List<Mission>> getSubMissions(String parentId) async {
    final filtered =
        _missions.where((m) => m.parentId == parentId).toList();
    filtered.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return filtered;
  }

  Future<List<Mission>> getMissionsByDate(DateTime date) async {
    final dateStr = date.toIso8601String().substring(0, 10);
    final filtered = _missions
        .where((m) =>
            m.dueDate != null &&
            m.dueDate!.toIso8601String().startsWith(dateStr))
        .toList();
    filtered.sort((a, b) {
      final cmp = b.priority.index.compareTo(a.priority.index);
      if (cmp != 0) return cmp;
      return a.orderIndex.compareTo(b.orderIndex);
    });
    return filtered;
  }

  Future<List<Mission>> getMissionsByStatus(MissionStatus status) async {
    final filtered =
        _missions.where((m) => m.status == status).toList();
    filtered.sort((a, b) {
      final cmp = b.priority.index.compareTo(a.priority.index);
      if (cmp != 0) return cmp;
      return b.createdAt.compareTo(a.createdAt);
    });
    return filtered;
  }

  Future<List<Mission>> getStarredMissions() async {
    final filtered = _missions.where((m) => m.isStarred).toList();
    filtered.sort((a, b) {
      final cmp = b.priority.index.compareTo(a.priority.index);
      if (cmp != 0) return cmp;
      return b.createdAt.compareTo(a.createdAt);
    });
    return filtered;
  }

  Future<int> updateMission(Mission mission) async {
    final idx = _missions.indexWhere((m) => m.id == mission.id);
    if (idx >= 0) {
      _missions[idx] = mission;
      await _saveMissions();
      return 1;
    }
    return 0;
  }

  Future<int> deleteMission(String id) async {
    _missions.removeWhere((m) => m.parentId == id);
    _missions.removeWhere((m) => m.id == id);
    await _saveMissions();
    return 1;
  }

  Future<Map<String, int>> getMissionStats() async {
    final total = _missions.length;
    final completed =
        _missions.where((m) => m.status == MissionStatus.completed).length;
    final pending =
        _missions.where((m) => m.status == MissionStatus.pending).length;
    final inProgress =
        _missions.where((m) => m.status == MissionStatus.inProgress).length;
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'inProgress': inProgress,
    };
  }

  Future<List<Mission>> getCompletedMissionsByDateRange(
      DateTime start, DateTime end) async {
    final filtered = _missions
        .where((m) =>
            m.status == MissionStatus.completed &&
            m.completedAt != null &&
            m.completedAt!.isAfter(start) &&
            m.completedAt!.isBefore(end))
        .toList();
    filtered.sort(
        (a, b) => (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));
    return filtered;
  }

  // ===== CHAT MESSAGES =====

  Future<int> insertChatMessage(ChatMessage message) async {
    final idx = _chatMessages.indexWhere((m) => m.id == message.id);
    if (idx >= 0) {
      _chatMessages[idx] = message;
    } else {
      _chatMessages.add(message);
    }
    await _saveChat();
    return 1;
  }

  Future<List<ChatMessage>> getChatMessages({int limit = 50}) async {
    final sorted = List<ChatMessage>.from(_chatMessages);
    sorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (sorted.length > limit) {
      return sorted.sublist(sorted.length - limit);
    }
    return sorted;
  }

  Future<List<ChatMessage>> getRecentChatMessages({int limit = 10}) async {
    final sorted = List<ChatMessage>.from(_chatMessages);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final recent = sorted.take(limit).toList();
    return recent.reversed.toList();
  }

  Future<int> clearChatHistory() async {
    final count = _chatMessages.length;
    _chatMessages.clear();
    await _saveChat();
    return count;
  }

  // ===== TOKEN USAGE =====

  Future<TokenUsage> getTodayTokenUsage(bool isPremium) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (!_tokenUsage.containsKey(today)) {
      _tokenUsage[today] = TokenUsage(
        date: today,
        tokensUsed: 0,
        tokenLimit: isPremium ? 10000 : 5000,
        isPremium: isPremium,
      );
      await _saveTokens();
    }
    return _tokenUsage[today]!;
  }

  Future<void> updateTokenUsage(String date, int tokensUsed) async {
    if (_tokenUsage.containsKey(date)) {
      final usage = _tokenUsage[date]!;
      _tokenUsage[date] = TokenUsage(
        date: usage.date,
        tokensUsed: tokensUsed,
        tokenLimit: usage.tokenLimit,
        isPremium: usage.isPremium,
      );
      await _saveTokens();
    }
  }

  Future<void> updateTokenLimit(String date, int tokenLimit) async {
    if (_tokenUsage.containsKey(date)) {
      final usage = _tokenUsage[date]!;
      _tokenUsage[date] = TokenUsage(
        date: usage.date,
        tokensUsed: usage.tokensUsed,
        tokenLimit: tokenLimit,
        isPremium: usage.isPremium,
      );
      await _saveTokens();
    }
  }

  Future<List<TokenUsage>> getTokenUsageHistory({int days = 30}) async {
    final sorted = _tokenUsage.values.toList();
    sorted.sort((a, b) => b.date.compareTo(a.date));
    if (sorted.length > days) {
      return sorted.sublist(0, days);
    }
    return sorted;
  }

  Future<void> close() async {
    // No-op for web
  }
}
