import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/habit.dart';
import '../models/habit_group.dart';
import '../services/notification_service.dart';

class HabitProvider with ChangeNotifier {
  final _box = Hive.box<Habit>('habits');
  final _groupBox = Hive.box<HabitGroup>('habit_groups');
  final _notificationService = NotificationService();
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  HabitProvider() {
    _habits = _box.values.toList();
  }

  void addHabit(
    String name,
    String groupId, {
    DateTime? reminderTime,
    String? customReminderText,
  }) {
    final habit = Habit(
      name: name,
      groupId: groupId,
      reminderTime: reminderTime,
      customReminderText: customReminderText,
    );
    _box.add(habit);
    _habits = _box.values.toList();
    
    // Schedule notification if reminder time is set
    if (reminderTime != null) {
      _notificationService.scheduleHabitReminder(habit);
    }
    
    notifyListeners();
  }

  void editHabit(
    Habit habit,
    String newName, {
    DateTime? reminderTime,
    String? customReminderText,
    bool clearReminder = false,
  }) {
    // Cancel existing reminder if any
    if (habit.reminderTime != null) {
      _notificationService.cancelHabitReminder(habit);
    }
    
    habit.name = newName;
    
    if (clearReminder) {
      habit.reminderTime = null;
      habit.customReminderText = null;
    } else {
      habit.reminderTime = reminderTime ?? habit.reminderTime;
      habit.customReminderText = customReminderText ?? habit.customReminderText;
    }
    
    habit.save();
    _habits = _box.values.toList();
    
    // Schedule new reminder if set
    if (habit.reminderTime != null) {
      _notificationService.scheduleHabitReminder(habit);
    }
    
    notifyListeners();
  }

  void deleteHabit(Habit habit) {
    // Cancel reminder before deleting
    if (habit.reminderTime != null) {
      _notificationService.cancelHabitReminder(habit);
    }
    
    habit.delete();
    _habits = _box.values.toList();
    notifyListeners();
  }

  void toggleComplete(Habit habit, DateTime date) {
    final today = DateTime.now();
    final isToday = date.year == today.year && 
                    date.month == today.month && 
                    date.day == today.day;
    
    final index = habit.completedDates.indexWhere((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);

    final wasCompleted = index >= 0;
    
    if (wasCompleted) {
      // Unmarking as done
      habit.completedDates.removeAt(index);
      
      // If this is today and habit has a reminder, reschedule it
      // (only if the reminder time hasn't passed yet)
      if (isToday && habit.reminderTime != null) {
        final reminderHour = habit.reminderTime!.hour;
        final reminderMinute = habit.reminderTime!.minute;
        final now = DateTime.now();
        final reminderTimeToday = DateTime(
          now.year, now.month, now.day, 
          reminderHour, reminderMinute
        );
        
        // Only reschedule if reminder time is still in the future
        if (reminderTimeToday.isAfter(now)) {
          _notificationService.scheduleHabitReminder(habit);
        }
      }
    } else {
      // Marking as done
      habit.completedDates.add(date);
      
      // If this is today and habit has a reminder, cancel today's notification
      if (isToday && habit.reminderTime != null) {
        _notificationService.cancelHabitReminder(habit);
      }
    }

    habit.save();
    _habits = _box.values.toList();
    
    // Handle group notification logic (only for today)
    if (isToday) {
      _updateGroupNotification(habit.groupId, wasCompleted);
    }
    
    notifyListeners();
  }
  
  /// Updates group notification based on whether all habits in the group are done
  void _updateGroupNotification(String groupId, bool habitWasCompleted) {
    // Find the group
    final group = _groupBox.values.firstWhere(
      (g) => g.id == groupId,
      orElse: () => HabitGroup(id: '', name: '', colorValue: 0),
    );
    
    debugPrint('🔍 Checking group notification for "${group.name}" (id: $groupId)');
    debugPrint('   Group has reminder: ${group.groupReminderTime != null}');
    
    // If group doesn't have a reminder, nothing to do
    if (group.id.isEmpty || group.groupReminderTime == null) {
      debugPrint('   ⏭️ Skipping - no reminder set');
      return;
    }
    
    final today = DateTime.now();
    
    // Get all habits in this group
    final groupHabits = _habits.where((h) => h.groupId == groupId).toList();
    debugPrint('   Found ${groupHabits.length} habits in group');
    
    // If no habits in group, nothing to check
    if (groupHabits.isEmpty) {
      debugPrint('   ⏭️ Skipping - no habits in group');
      return;
    }
    
    // Check if all habits in the group are done today
    final allDoneToday = groupHabits.every((h) {
      final isDone = h.completedDates.any((d) =>
          d.year == today.year && d.month == today.month && d.day == today.day);
      debugPrint('   - "${h.name}": done=$isDone');
      return isDone;
    });
    
    debugPrint('   All done today: $allDoneToday');
    
    if (allDoneToday) {
      // All habits done - cancel the group notification
      debugPrint('   ✅ All habits done - CANCELLING group notification');
      _notificationService.cancelGroupReminder(group);
    } else if (habitWasCompleted) {
      // A habit was unmarked and not all are done - reschedule group notification
      // (only if the reminder time hasn't passed yet)
      final reminderHour = group.groupReminderTime!.hour;
      final reminderMinute = group.groupReminderTime!.minute;
      final now = DateTime.now();
      final reminderTimeToday = DateTime(
        now.year, now.month, now.day, 
        reminderHour, reminderMinute
      );
      
      if (reminderTimeToday.isAfter(now)) {
        debugPrint('   🔄 Rescheduling group notification');
        _notificationService.scheduleGroupReminder(group, _habits);
      }
    }
  }

  void deleteHabitsForGroup(String groupId) {
    final toDelete = _habits.where((h) => h.groupId == groupId).toList();
    for (var h in toDelete) {
      // Cancel reminders before deleting
      if (h.reminderTime != null) {
        _notificationService.cancelHabitReminder(h);
      }
      h.delete();
    }
    _habits = _box.values.toList();
    notifyListeners();
  }
}

