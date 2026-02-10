import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    if (kIsWeb) return; // Notifications not supported on web
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

  Future<void> showMissionReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      'mission_reminders',
      'Mission Reminders',
      channelDescription: 'Reminders for your missions',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2D5A27),
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

  Future<void> showDailyReport({
    required int completedCount,
    required int pendingCount,
  }) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      'daily_reports',
      'Daily Reports',
      channelDescription: 'Daily mission reports',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFFD700),
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      9999,
      'Daily Report, Commander 🫡',
      'Yes Sir. $completedCount missions completed. $pendingCount pending.',
      details,
    );
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
