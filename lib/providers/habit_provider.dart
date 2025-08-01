import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/habit.dart';

class HabitProvider with ChangeNotifier {
  final _box = Hive.box<Habit>('habits');
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  HabitProvider() {
    _habits = _box.values.toList();
  }

  void addHabit(String name, String groupId) {
    final habit = Habit(name: name, groupId: groupId);
    _box.add(habit);
    _habits = _box.values.toList();
    notifyListeners();
  }

  void editHabit(Habit habit, String newName) {
    habit.name = newName;
    habit.save();
    _habits = _box.values.toList();
    notifyListeners();
  }

  void deleteHabit(Habit habit) {
    habit.delete();
    _habits = _box.values.toList();
    notifyListeners();
  }

  void toggleComplete(Habit habit, DateTime date) {
    final index = habit.completedDates.indexWhere((d) =>
    d.year == date.year && d.month == date.month && d.day == date.day);

    if (index >= 0) {
      habit.completedDates.removeAt(index);
    } else {
      habit.completedDates.add(date);
    }

    habit.save();
    _habits = _box.values.toList();
    notifyListeners();
  }

  void deleteHabitsForGroup(String groupId) {
    final toDelete = _habits.where((h) => h.groupId == groupId).toList();
    for (var h in toDelete) {
      h.delete();
    }
    _habits = _box.values.toList();
    notifyListeners();
  }
}
