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

  Habit({
    required this.name,
    required this.groupId,
    List<DateTime>? completedDates,
  }) : completedDates = completedDates ?? [];
}
