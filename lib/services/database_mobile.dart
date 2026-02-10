import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mission.dart';
import '../models/chat_message.dart';
import '../models/token_usage.dart';

/// Mobile implementation using sqflite.
class PlatformDatabase {
  Database? _database;

  Future<void> initialize() async {
    if (_database != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'yessir.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<Database> get _db async {
    if (_database == null) await initialize();
    return _database!;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE missions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT DEFAULT '',
        priority INTEGER DEFAULT 1,
        status INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        dueDate TEXT,
        completedAt TEXT,
        isStarred INTEGER DEFAULT 0,
        parentId TEXT,
        recurrence INTEGER DEFAULT 0,
        subMissionIds TEXT DEFAULT '',
        orderIndex INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        role INTEGER NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        tokensUsed INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE token_usage (
        date TEXT PRIMARY KEY,
        tokensUsed INTEGER DEFAULT 0,
        tokenLimit INTEGER DEFAULT 5000,
        isPremium INTEGER DEFAULT 0
      )
    ''');
  }

  // ===== MISSIONS =====

  Future<int> insertMission(Mission mission) async {
    final db = await _db;
    return await db.insert('missions', mission.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Mission>> getAllMissions() async {
    final db = await _db;
    final result =
        await db.query('missions', orderBy: 'orderIndex ASC, createdAt DESC');
    return result.map((map) => Mission.fromMap(map)).toList();
  }

  Future<List<Mission>> getTopLevelMissions() async {
    final db = await _db;
    final result = await db.query('missions',
        where: 'parentId IS NULL',
        orderBy: 'orderIndex ASC, createdAt DESC');
    return result.map((map) => Mission.fromMap(map)).toList();
  }

  Future<List<Mission>> getSubMissions(String parentId) async {
    final db = await _db;
    final result = await db.query('missions',
        where: 'parentId = ?',
        whereArgs: [parentId],
        orderBy: 'orderIndex ASC');
    return result.map((map) => Mission.fromMap(map)).toList();
  }

  Future<List<Mission>> getMissionsByDate(DateTime date) async {
    final db = await _db;
    final dateStr = date.toIso8601String().substring(0, 10);
    final result = await db.query('missions',
        where: 'dueDate LIKE ?',
        whereArgs: ['$dateStr%'],
        orderBy: 'priority DESC, orderIndex ASC');
    return result.map((map) => Mission.fromMap(map)).toList();
  }

  Future<List<Mission>> getMissionsByStatus(MissionStatus status) async {
    final db = await _db;
    final result = await db.query('missions',
        where: 'status = ?',
        whereArgs: [status.index],
        orderBy: 'priority DESC, createdAt DESC');
    return result.map((map) => Mission.fromMap(map)).toList();
  }

  Future<List<Mission>> getStarredMissions() async {
    final db = await _db;
    final result = await db.query('missions',
        where: 'isStarred = 1',
        orderBy: 'priority DESC, createdAt DESC');
    return result.map((map) => Mission.fromMap(map)).toList();
  }

  Future<int> updateMission(Mission mission) async {
    final db = await _db;
    return await db.update('missions', mission.toMap(),
        where: 'id = ?', whereArgs: [mission.id]);
  }

  Future<int> deleteMission(String id) async {
    final db = await _db;
    await db.delete('missions', where: 'parentId = ?', whereArgs: [id]);
    return await db.delete('missions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> getMissionStats() async {
    final db = await _db;
    final total = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM missions'));
    final completed = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM missions WHERE status = ${MissionStatus.completed.index}'));
    final pending = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM missions WHERE status = ${MissionStatus.pending.index}'));
    final inProgress = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM missions WHERE status = ${MissionStatus.inProgress.index}'));

    return {
      'total': total ?? 0,
      'completed': completed ?? 0,
      'pending': pending ?? 0,
      'inProgress': inProgress ?? 0,
    };
  }

  Future<List<Mission>> getCompletedMissionsByDateRange(
      DateTime start, DateTime end) async {
    final db = await _db;
    final result = await db.query('missions',
        where: 'status = ? AND completedAt >= ? AND completedAt <= ?',
        whereArgs: [
          MissionStatus.completed.index,
          start.toIso8601String(),
          end.toIso8601String(),
        ],
        orderBy: 'completedAt DESC');
    return result.map((map) => Mission.fromMap(map)).toList();
  }

  // ===== CHAT MESSAGES =====

  Future<int> insertChatMessage(ChatMessage message) async {
    final db = await _db;
    return await db.insert('chat_messages', message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ChatMessage>> getChatMessages({int limit = 50}) async {
    final db = await _db;
    final result = await db.query('chat_messages',
        orderBy: 'timestamp ASC', limit: limit);
    return result.map((map) => ChatMessage.fromMap(map)).toList();
  }

  Future<List<ChatMessage>> getRecentChatMessages({int limit = 10}) async {
    final db = await _db;
    final result = await db.query('chat_messages',
        orderBy: 'timestamp DESC', limit: limit);
    return result.reversed.map((map) => ChatMessage.fromMap(map)).toList();
  }

  Future<int> clearChatHistory() async {
    final db = await _db;
    return await db.delete('chat_messages');
  }

  // ===== TOKEN USAGE =====

  Future<TokenUsage> getTodayTokenUsage(bool isPremium) async {
    final db = await _db;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result =
        await db.query('token_usage', where: 'date = ?', whereArgs: [today]);

    if (result.isEmpty) {
      final usage = TokenUsage(
        date: today,
        tokensUsed: 0,
        tokenLimit: isPremium ? 10000 : 5000,
        isPremium: isPremium,
      );
      await db.insert('token_usage', usage.toMap());
      return usage;
    }

    return TokenUsage.fromMap(result.first);
  }

  Future<void> updateTokenUsage(String date, int tokensUsed) async {
    final db = await _db;
    await db.update('token_usage', {'tokensUsed': tokensUsed},
        where: 'date = ?', whereArgs: [date]);
  }

  Future<List<TokenUsage>> getTokenUsageHistory({int days = 30}) async {
    final db = await _db;
    final result =
        await db.query('token_usage', orderBy: 'date DESC', limit: days);
    return result.map((map) => TokenUsage.fromMap(map)).toList();
  }

  Future<void> close() async {
    _database?.close();
  }
}
