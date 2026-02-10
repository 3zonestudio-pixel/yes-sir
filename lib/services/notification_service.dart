import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    if (kIsWeb) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  /// Show a mission reminder notification
  Future<void> showMissionReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      'mission_reminders',
      'Mission Reminders',
      channelDescription: 'Smart reminders for your missions',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2D6A4F),
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  /// Show a due-soon warning notification
  Future<void> showDueSoonReminder({
    required int id,
    required String missionTitle,
    required Duration timeRemaining,
  }) async {
    if (kIsWeb) return;

    String timeText;
    if (timeRemaining.inHours > 0) {
      timeText = '${timeRemaining.inHours}h remaining';
    } else if (timeRemaining.inMinutes > 0) {
      timeText = '${timeRemaining.inMinutes}min remaining';
    } else {
      timeText = 'Due now!';
    }

    const androidDetails = AndroidNotificationDetails(
      'due_soon',
      'Due Soon Alerts',
      channelDescription: 'Alerts for missions about to be due',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFFD166),
      styleInformation: BigTextStyleInformation(''),
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id + 10000,
      '⏰ $missionTitle',
      '$timeText — Don\'t forget to complete this mission!',
      details,
    );
  }

  /// Show daily briefing notification
  Future<void> showDailyBriefing({
    required int completedCount,
    required int pendingCount,
    required int overdueCount,
  }) async {
    if (kIsWeb) return;

    String body;
    if (overdueCount > 0) {
      body = '⚠️ $overdueCount overdue, $pendingCount pending. Let\'s catch up today!';
    } else if (pendingCount == 0) {
      body = '🎉 All clear! No pending missions. Great work!';
    } else {
      body = '📋 $pendingCount missions waiting. You\'ve completed $completedCount so far!';
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_briefing',
      'Daily Briefing',
      channelDescription: 'Daily morning briefing about your missions',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF52B788),
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      9999,
      '☀️ Good morning!',
      body,
      details,
    );
  }

  /// Show daily report notification
  Future<void> showDailyReport({
    required int completedCount,
    required int pendingCount,
  }) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      'daily_reports',
      'Daily Reports',
      channelDescription: 'Daily mission progress reports',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFFD166),
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      9998,
      '📊 Daily Report',
      '$completedCount completed, $pendingCount pending. ${completedCount > 0 ? "Great progress! 💪" : "Tomorrow is a new day! ✨"}',
      details,
    );
  }

  /// Show achievement/streak notification
  Future<void> showAchievement({
    required String title,
    required String message,
  }) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      'achievements',
      'Achievements',
      channelDescription: 'Celebrate your achievements',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFFD166),
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(9997, '🏆 $title', message, details);
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
