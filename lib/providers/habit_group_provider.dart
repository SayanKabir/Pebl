import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/habit_group.dart';

class HabitGroupProvider with ChangeNotifier {
  final _box = Hive.box<HabitGroup>('habit_groups');
  final _uuid = Uuid();

  List<HabitGroup> _groups = [];
  List<HabitGroup> get groups => _groups;

  HabitGroupProvider() {
    _groups = _box.values.toList();
  }

  void addGroup(String name, Color color) {
    final id = _uuid.v4();
    final group = HabitGroup(id: id, name: name, colorValue: color.value);
    _box.add(group);
    _groups = _box.values.toList();
    notifyListeners();
  }

  void editGroup(String id, String newName, Color newColor) {
    final group = _groups.firstWhere((g) => g.id == id);
    group.name = newName;
    group.colorValue = newColor.value;
    group.save();
    _groups = _box.values.toList();
    notifyListeners();
  }

  void deleteGroup(String id, void Function(String) deleteHabitsCallback) {
    if (_groups.length <= 1) return;
    deleteHabitsCallback(id);
    final target = _groups.firstWhere((g) => g.id == id);
    target.delete();
    _groups = _box.values.toList();
    notifyListeners();
  }
}
