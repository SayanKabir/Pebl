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

    for (int i = 0; i <= 34; i++) {
      final rawDate = today.subtract(Duration(days: i));
      final date = DateTime(rawDate.year, rawDate.month, rawDate.day);

      double maxPercent = 0;
      Color? selectedColor;

      for (final group in groups) {
        final groupHabits = habits.where((h) => h.groupId == group.id).toList();

        if (groupHabits.isEmpty) continue;

        final total = groupHabits.length;
        final done = groupHabits.where((h) =>
            h.completedDates.any((d) =>
            d.year == date.year && d.month == date.month && d.day == date.day)).length;

        final percent = total > 0 ? (done / total) : 0.0;

        if (percent > maxPercent) {
          maxPercent = percent;
          selectedColor = Color(group.colorValue);
        }
      }

      if (selectedColor != null && maxPercent > 0) {
        final normalizedLevel = (maxPercent * 10).ceil().clamp(1, 10);
        final key = normalizedLevel * 1000 + selectedColor.value % 1000;

        if (!colorSet.containsKey(key)) {
          colorSet[key] = selectedColor.withValues(alpha: maxPercent.clamp(0.1, 1.0));
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
      defaultColor: MyConstants.lightBlack,
      size: 36,
      borderRadius: 6,
      colorMode: ColorMode.color,
      colorsets: colorSet,
    );
  }
}
