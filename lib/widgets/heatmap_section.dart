import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:pebl/constants.dart';
import '../models/habit.dart';
import '../models/habit_group.dart';

class HeatmapSection extends StatelessWidget {
  final List<HabitGroup> groups;
  final List<Habit> habits;

  const HeatmapSection({
    super.key,
    required this.groups,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final Map<DateTime, int> data = {};
    final Map<int, Color> colorSet = {};
    final Map<String, int> colorSetKeys = {};
    int nextKey = 0;

    for (int i = 0; i <= 34; i++) {
      final rawDate = today.subtract(Duration(days: i));
      final date = DateTime(rawDate.year, rawDate.month, rawDate.day);

      double totalRed = 0;
      double totalGreen = 0;
      double totalBlue = 0;
      int doneCount = 0;
      int totalHabitsCount = 0;

      for (final group in groups) {
        final groupHabits = habits.where((h) => h.groupId == group.id).toList();
        if (groupHabits.isEmpty) continue;

        totalHabitsCount += groupHabits.length;
        
        final groupDoneCount = groupHabits.where((h) =>
            h.completedDates.any((d) =>
            d.year == date.year && d.month == date.month && d.day == date.day)).length;

        if (groupDoneCount > 0) {
          final color = Color(group.colorValue);
          totalRed += color.r * groupDoneCount;
          totalGreen += color.g * groupDoneCount;
          totalBlue += color.b * groupDoneCount;
          doneCount += groupDoneCount;
        }
      }

      if (doneCount > 0) {
        final avgRed = (totalRed / doneCount * 255).round();
        final avgGreen = (totalGreen / doneCount * 255).round();
        final avgBlue = (totalBlue / doneCount * 255).round();
        
        final blendedColor = Color.fromARGB(255, avgRed, avgGreen, avgBlue);
        final completionRate = totalHabitsCount > 0 ? (doneCount / totalHabitsCount) : 0.0;
        
        final normalizedLevel = (completionRate * 10).ceil().clamp(1, 10);
        final cacheKey = "${blendedColor.value}_$normalizedLevel";
        final int key;

        if (colorSetKeys.containsKey(cacheKey)) {
           key = colorSetKeys[cacheKey]!;
        } else {
           key = nextKey++;
           colorSetKeys[cacheKey] = key;
           colorSet[key] = blendedColor.withValues(alpha: completionRate.clamp(0.2, 0.85));
        }

        data[date] = key;
      }
    }

    return HeatMapCalendar(
      flexible: true,
      datasets: data,
      showColorTip: false,
      textColor: Colors.white,
      weekTextColor: Colors.grey[400],
      defaultColor: Colors.white.withValues(alpha: 0.1),
      size: 36,
      borderRadius: 6,
      colorMode: ColorMode.color,
      colorsets: colorSet,
    );
  }
}
