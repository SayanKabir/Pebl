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

  HabitGroup({required this.id, required this.name, required this.colorValue});
}
