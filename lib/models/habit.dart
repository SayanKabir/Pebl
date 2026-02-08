import 'package:hive/hive.dart';
part 'habit.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String groupId;

  @HiveField(2)
  List<DateTime> completedDates;

  /// Reminder time for this habit (only hour:minute matters, scheduled daily)
  @HiveField(3)
  DateTime? reminderTime;

  /// Custom notification text, e.g., "Time to practice meditation! 🧘"
  @HiveField(4)
  String? customReminderText;

  Habit({
    required this.name,
    required this.groupId,
    List<DateTime>? completedDates,
    this.reminderTime,
    this.customReminderText,
  }) : completedDates = completedDates ?? [];
}
