import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/habit.dart';
import '../models/habit_group.dart';

/// Notification service for scheduling habit reminders.
/// Follows the pattern from Pilzy's notification implementation.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  
  final _random = Random();

  /// Beautiful motivational messages for habit reminders
  static const List<String> _habitMessages = [
    "Small steps lead to big changes 🌱",
    "You're building something amazing ✨",
    "Consistency is your superpower 💪",
    "One step at a time, one day at a time 🚶",
    "Your future self will thank you 🙏",
    "Progress, not perfection 🎯",
    "Every day is a fresh start 🌅",
    "You've got this! 🔥",
    "Make today count 📈",
    "The best time is now ⏰",
    "Keep the streak alive! 🔗",
    "Building habits, building life 🏗️",
    "Tiny wins add up 🏆",
    "Stay committed, stay strong 💎",
    "Your consistency inspires 🌟",
  ];

  static const List<String> _groupMessages = [
    "Time to focus on what matters 🎯",
    "Your routine awaits ✨",
    "Let's make progress together 🤝",
    "Ready for your habits? 🚀",
    "Another day, another opportunity 🌈",
    "Your habits are calling 📞",
    "Time to build your best self 💪",
    "Stay on track! 🛤️",
  ];

  String _getRandomHabitMessage() => _habitMessages[_random.nextInt(_habitMessages.length)];
  String _getRandomGroupMessage() => _groupMessages[_random.nextInt(_groupMessages.length)];

  /// Initialize the notification service
  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('🔔 Notification clicked: ${response.payload}');
      },
    );

    _initialized = true;
    debugPrint('✅ NotificationService initialized');
  }

  // ─────────────────────────────────────────────────────────────
  // 🔄 RESCHEDULE ALL (Safety Net on App Startup)
  // ─────────────────────────────────────────────────────────────

  /// Cancels all existing notifications and re-schedules them based on current data.
  /// Call this in main.dart after initializing services.
  /// Skips habits that are already completed for today.
  Future<void> rescheduleAll({
    required List<Habit> habits,
    required List<HabitGroup> groups,
  }) async {
    debugPrint('🔄 Rescheduling all habit reminders...');

    // Clear everything to prevent duplicates
    await _notificationsPlugin.cancelAll();

    final today = DateTime.now();
    
    // Helper to check if habit is completed today
    bool isCompletedToday(Habit habit) {
      return habit.completedDates.any((d) =>
          d.year == today.year && d.month == today.month && d.day == today.day);
    }

    // Schedule individual habit reminders (skip if already done today)
    for (var habit in habits) {
      if (habit.reminderTime != null && !isCompletedToday(habit)) {
        await scheduleHabitReminder(habit);
      }
    }

    // Schedule group reminders (skip if all habits in group are done today)
    for (var group in groups) {
      if (group.groupReminderTime != null) {
        // Get habits in this group
        final groupHabits = habits.where((h) => h.groupId == group.id).toList();
        
        // Check if all habits in the group are done today
        final allDoneToday = groupHabits.isNotEmpty && groupHabits.every((h) => isCompletedToday(h));
        
        if (!allDoneToday) {
          await scheduleGroupReminder(group, habits);
        } else {
          debugPrint('⏭️ Skipping group "${group.name}" - all habits done today');
        }
      }
    }

    debugPrint('✅ All habit reminders rescheduled');
  }

  // ─────────────────────────────────────────────────────────────
  // 🔔 HABIT REMINDERS
  // ─────────────────────────────────────────────────────────────

  /// Schedule a daily reminder for a specific habit
  Future<void> scheduleHabitReminder(Habit habit) async {
    if (habit.reminderTime == null) return;

    final notificationId = habit.key.hashCode;
    final title = habit.name;
    final body = _getRandomHabitMessage();

    await _scheduleDaily(
      id: notificationId,
      title: title,
      body: body,
      hour: habit.reminderTime!.hour,
      minute: habit.reminderTime!.minute,
      payload: 'habit_${habit.key}',
    );

    debugPrint('📅 Scheduled reminder for habit "${habit.name}" at ${habit.reminderTime!.hour}:${habit.reminderTime!.minute}');
  }

  /// Cancel reminder for a specific habit
  Future<void> cancelHabitReminder(Habit habit) async {
    final notificationId = habit.key.hashCode;
    await _notificationsPlugin.cancel(notificationId);
    debugPrint('🔕 Cancelled reminder for habit "${habit.name}"');
  }

  // ─────────────────────────────────────────────────────────────
  // 🔔 GROUP REMINDERS
  // ─────────────────────────────────────────────────────────────

  /// Schedule a daily reminder for a habit group
  Future<void> scheduleGroupReminder(HabitGroup group, List<Habit> allHabits) async {
    if (group.groupReminderTime == null) return;

    final notificationId = group.id.hashCode;
    final title = group.name;
    final body = _getRandomGroupMessage();

    await _scheduleDaily(
      id: notificationId,
      title: title,
      body: body,
      hour: group.groupReminderTime!.hour,
      minute: group.groupReminderTime!.minute,
      payload: 'group_${group.id}',
    );

    debugPrint('📅 Scheduled group reminder for "${group.name}" at ${group.groupReminderTime!.hour}:${group.groupReminderTime!.minute} (notificationId: $notificationId, groupId: ${group.id})');
  }

  /// Cancel reminder for a specific group
  Future<void> cancelGroupReminder(HabitGroup group) async {
    final notificationId = group.id.hashCode;
    await _notificationsPlugin.cancel(notificationId);
    debugPrint('🔕 Cancelled group reminder for "${group.name}" (notificationId: $notificationId, groupId: ${group.id})');
  }

  // ─────────────────────────────────────────────────────────────
  // 🛠️ CORE SCHEDULING LOGIC
  // ─────────────────────────────────────────────────────────────

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
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

    // Calculate next occurrence
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🔓 PERMISSIONS
  // ─────────────────────────────────────────────────────────────

  /// Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    }
    return true; // iOS handles this during init
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Check if exact alarm permission is granted (Android 12+)
  Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    return await Permission.scheduleExactAlarm.isGranted;
  }

  /// Request exact alarm permission (Android 12+)
  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    if (await hasExactAlarmPermission()) return;

    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    await intent.launch();
  }

  /// Request all necessary permissions
  Future<bool> requestAllPermissions() async {
    bool notificationGranted = await requestNotificationPermission();
    
    if (Platform.isAndroid) {
      if (!await hasExactAlarmPermission()) {
        await requestExactAlarmPermission();
      }
    }
    
    return notificationGranted;
  }
}
