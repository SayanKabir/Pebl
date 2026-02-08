import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/habit_group.dart';
import '../services/notification_service.dart';

class HabitGroupProvider with ChangeNotifier {
  final _box = Hive.box<HabitGroup>('habit_groups');
  final _habitBox = Hive.box<Habit>('habits');
  final _uuid = Uuid();
  final _notificationService = NotificationService();

  List<HabitGroup> _groups = [];
  List<HabitGroup> get groups => _groups;

  HabitGroupProvider() {
    _groups = _box.values.toList();
  }

  void addGroup(
    String name,
    Color color, {
    DateTime? groupReminderTime,
    String? groupReminderText,
  }) {
    final id = _uuid.v4();
    final group = HabitGroup(
      id: id,
      name: name,
      colorValue: color.value,
      groupReminderTime: groupReminderTime,
      groupReminderText: groupReminderText,
    );
    _box.add(group);
    _groups = _box.values.toList();
    
    // Schedule group reminder if set
    if (groupReminderTime != null) {
      final habits = _habitBox.values.toList();
      _notificationService.scheduleGroupReminder(group, habits);
    }
    
    notifyListeners();
  }

  void editGroup(
    String id,
    String newName,
    Color newColor, {
    DateTime? groupReminderTime,
    String? groupReminderText,
    bool clearReminder = false,
  }) {
    final group = _groups.firstWhere((g) => g.id == id);
    
    // Cancel existing group reminder if any
    if (group.groupReminderTime != null) {
      _notificationService.cancelGroupReminder(group);
    }
    
    group.name = newName;
    group.colorValue = newColor.value;
    
    if (clearReminder) {
      group.groupReminderTime = null;
      group.groupReminderText = null;
    } else {
      group.groupReminderTime = groupReminderTime ?? group.groupReminderTime;
      group.groupReminderText = groupReminderText ?? group.groupReminderText;
    }
    
    group.save();
    _groups = _box.values.toList();
    
    // Schedule new group reminder if set
    if (group.groupReminderTime != null) {
      final habits = _habitBox.values.toList();
      _notificationService.scheduleGroupReminder(group, habits);
    }
    
    notifyListeners();
  }

  void deleteGroup(String id, void Function(String) deleteHabitsCallback) {
    if (_groups.length <= 1) return;
    
    final target = _groups.firstWhere((g) => g.id == id);
    
    // Cancel group reminder before deleting
    if (target.groupReminderTime != null) {
      _notificationService.cancelGroupReminder(target);
    }
    
    deleteHabitsCallback(id);
    target.delete();
    _groups = _box.values.toList();
    notifyListeners();
  }
}

