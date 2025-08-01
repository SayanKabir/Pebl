import '../models/habit.dart';

class StreakInfo {
  final int current;
  final int max;
  StreakInfo({required this.current, required this.max});
}

StreakInfo calculateStreak(List<Habit> habits, String groupId) {
  final today = DateTime.now();
  final datesDone = <DateTime>{};

  for (final h in habits.where((h) => h.groupId == groupId)) {
    for (var d in h.completedDates) {
      datesDone.add(DateTime(d.year, d.month, d.day));
    }
  }

  final sortedDays = datesDone.toList()
    ..sort((a, b) => b.compareTo(a));

  int current = 0, max = 0, streak = 0;
  DateTime day = today;

  while (true) {
    if (datesDone.contains(DateTime(day.year, day.month, day.day))) {
      current++;
      streak++;
      day = day.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }

  for (final d in sortedDays) {
    DateTime cursor = d;
    int temp = 0;
    while (datesDone.contains(DateTime(cursor.year, cursor.month, cursor.day))) {
      temp++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    if (temp > max) max = temp;
  }

  return StreakInfo(current: current, max: max);
}
