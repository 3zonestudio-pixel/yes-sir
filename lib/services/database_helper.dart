import '../models/mission.dart';
import '../models/chat_message.dart';
import '../models/token_usage.dart';

// Conditional imports: sqflite only on mobile
import 'database_mobile.dart' if (dart.library.html) 'database_web.dart'
    as platform_db;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  late final platform_db.PlatformDatabase _platformDb;
  bool _initialized = false;

  DatabaseHelper._init() {
    _platformDb = platform_db.PlatformDatabase();
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _platformDb.initialize();
      _initialized = true;
    }
  }

  // ===== MISSIONS =====

  Future<int> insertMission(Mission mission) async {
    await _ensureInitialized();
    return await _platformDb.insertMission(mission);
  }

  Future<List<Mission>> getAllMissions() async {
    await _ensureInitialized();
    return await _platformDb.getAllMissions();
  }

  Future<List<Mission>> getTopLevelMissions() async {
    await _ensureInitialized();
    return await _platformDb.getTopLevelMissions();
  }

  Future<List<Mission>> getSubMissions(String parentId) async {
    await _ensureInitialized();
    return await _platformDb.getSubMissions(parentId);
  }

  Future<List<Mission>> getMissionsByDate(DateTime date) async {
    await _ensureInitialized();
    return await _platformDb.getMissionsByDate(date);
  }

  Future<List<Mission>> getMissionsByStatus(MissionStatus status) async {
    await _ensureInitialized();
    return await _platformDb.getMissionsByStatus(status);
  }

  Future<List<Mission>> getStarredMissions() async {
    await _ensureInitialized();
    return await _platformDb.getStarredMissions();
  }

  Future<int> updateMission(Mission mission) async {
    await _ensureInitialized();
    return await _platformDb.updateMission(mission);
  }

  Future<int> deleteMission(String id) async {
    await _ensureInitialized();
    return await _platformDb.deleteMission(id);
  }

  Future<Map<String, int>> getMissionStats() async {
    await _ensureInitialized();
    return await _platformDb.getMissionStats();
  }

  Future<List<Mission>> getCompletedMissionsByDateRange(
      DateTime start, DateTime end) async {
    await _ensureInitialized();
    return await _platformDb.getCompletedMissionsByDateRange(start, end);
  }

  // ===== CHAT MESSAGES =====

  Future<int> insertChatMessage(ChatMessage message) async {
    await _ensureInitialized();
    return await _platformDb.insertChatMessage(message);
  }

  Future<List<ChatMessage>> getChatMessages({int limit = 50}) async {
    await _ensureInitialized();
    return await _platformDb.getChatMessages(limit: limit);
  }

  Future<List<ChatMessage>> getRecentChatMessages({int limit = 10}) async {
    await _ensureInitialized();
    return await _platformDb.getRecentChatMessages(limit: limit);
  }

  Future<int> clearChatHistory() async {
    await _ensureInitialized();
    return await _platformDb.clearChatHistory();
  }

  // ===== TOKEN USAGE =====

  Future<TokenUsage> getTodayTokenUsage(bool isPremium) async {
    await _ensureInitialized();
    return await _platformDb.getTodayTokenUsage(isPremium);
  }

  Future<void> updateTokenUsage(String date, int tokensUsed) async {
    await _ensureInitialized();
    return await _platformDb.updateTokenUsage(date, tokensUsed);
  }

  Future<void> updateTokenLimit(String date, int tokenLimit) async {
    await _ensureInitialized();
    return await _platformDb.updateTokenLimit(date, tokenLimit);
  }

  Future<List<TokenUsage>> getTokenUsageHistory({int days = 30}) async {
    await _ensureInitialized();
    return await _platformDb.getTokenUsageHistory(days: days);
  }

  Future<void> close() async {
    await _platformDb.close();
  }
}
