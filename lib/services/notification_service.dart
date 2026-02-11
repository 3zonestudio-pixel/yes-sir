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

    // Request notification permission on Android 13+
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// Schedule a task reminder notification at a specific time
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required DateTime dueDate,
    Duration reminderBefore = const Duration(minutes: 30),
  }) async {
    if (kIsWeb) return;

    final reminderTime = dueDate.subtract(reminderBefore);
    final now = DateTime.now();

    // If reminder time is in the past, don't schedule
    if (reminderTime.isBefore(now)) return;

    // Calculate delay from now
    final delay = reminderTime.difference(now);

    // Use a hash of taskId as notification id
    final notifId = taskId.hashCode.abs() % 100000;

    // Schedule using a delayed show
    Future.delayed(delay, () async {
      await showMissionReminder(
        id: notifId,
        title: '⏰ Task Reminder',
        body: '"$title" is due soon!',
      );
    });
  }

  /// Show an immediate task reminder notification
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
      color: Color(0xFF42A5F5),
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
      color: Color(0xFFFF9F1C),
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

  /// Check all tasks and send reminders for due-soon ones
  Future<void> checkAndNotifyDueTasks(List<dynamic> missions) async {
    if (kIsWeb) return;
    final now = DateTime.now();

    for (final mission in missions) {
      if (mission.dueDate == null) continue;
      if (mission.status.index == 2) continue; // completed

      final diff = mission.dueDate!.difference(now);

      // Notify if due within 1 hour
      if (diff.inMinutes > 0 && diff.inMinutes <= 60) {
        await showDueSoonReminder(
          id: mission.id.hashCode.abs() % 100000,
          missionTitle: mission.title,
          timeRemaining: diff,
        );
      }
    }
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
