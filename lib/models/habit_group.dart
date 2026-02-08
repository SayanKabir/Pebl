import 'package:hive/hive.dart';
part 'habit_group.g.dart';

@HiveType(typeId: 0)
class HabitGroup extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  /// Group reminder time - applies to all habits in this group (daily)
  @HiveField(3)
  DateTime? groupReminderTime;

  /// Custom notification text for group reminder
  @HiveField(4)
  String? groupReminderText;

  HabitGroup({
    required this.id,
    required this.name,
    required this.colorValue,
    this.groupReminderTime,
    this.groupReminderText,
  });
}
