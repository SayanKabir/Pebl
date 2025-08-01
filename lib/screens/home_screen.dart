import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/habit.dart';
import '../models/habit_group.dart';
import '../providers/habit_group_provider.dart';
import '../providers/habit_provider.dart';
import '../utils/streak_utils.dart';
import '../widgets/heatmap_section.dart';
import '../widgets/pebl_habit_tile.dart';
import '../widgets/pebl_bottom_navbar.dart';
import '../widgets/streak_badge.dart';
import '../widgets/group_dialogs.dart';
import '../widgets/habit_dialogs.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:vibration/vibration.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedGroupIndex = 0;
  bool _showCalendar = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gp = context.read<HabitGroupProvider>().groups;
      if (gp.isEmpty) {
        context.read<HabitGroupProvider>().addGroup(
          'My Pebls',
          MyConstants.flamePebbleColors[0],
        );
      }
    });
    _scheduleMidnightRebuild();
  }

  void _scheduleMidnightRebuild() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    Future.delayed(nextMidnight.difference(now), () {
      if (mounted) setState(() {});
      _scheduleMidnightRebuild();
    });
  }

  bool _isDoneToday(Habit h) {
    final now = DateTime.now();
    return h.completedDates.any((d) =>
    d.year == now.year && d.month == now.month && d.day == now.day);
  }

  void _onToggleHabit(Habit h) {
    final provider = context.read<HabitProvider>();
    provider.toggleComplete(h, DateTime.now());

    final currentGroupId = context.read<HabitGroupProvider>().groups[_selectedGroupIndex].id;
    final allDone = context
        .read<HabitProvider>()
        .habits
        .where((x) => x.groupId == currentGroupId)
        .every((x) => _isDoneToday(x));

    if (allDone) {
      _launchConfetti();
      _vibrate();
    }
  }

  void _vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100, amplitude: 16);
    }
  }

  void _launchConfetti() {
    Confetti.launch(context, options: const ConfettiOptions(particleCount: 100, spread: 70, y: 0.8));
  }

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<HabitGroupProvider>().groups;
    final habits = context.watch<HabitProvider>().habits;

    if (groups.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedGroup = groups[_selectedGroupIndex];
    final groupHabits = habits.where((h) => h.groupId == selectedGroup.id).toList();

    return Scaffold(
      backgroundColor: MyConstants.mediumBlack,

      // APPBAR
      appBar: AppBar(
        toolbarHeight: 60,

        // LOGO
        title: Container(
          width: 100, height: 60,
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/pebl2.png'), fit: BoxFit.contain),
          ),
        ),
        backgroundColor: MyConstants.mediumBlack,
        elevation: 0,
        actions: [

          // SHOW/HIDE HEATMAP BUTTON
          IconButton(
            icon: Icon(_showCalendar ? Icons.expand_less : Icons.expand_more, color: Colors.white),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),

          // ADD HABIT BUTTON
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              HabitDialogs.showAddHabitDialog(context, selectedGroup.id);
            },
          ),

          // ROW OF STREAKS
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                for (int i = 0; i < groups.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Builder(builder: (_) {
                      final streak = calculateStreak(habits, groups[i].id).current;
                      final color = streak > 0
                          ? Color(groups[i].colorValue)
                          : MyConstants.mutedTextColor;

                      return StreakBadge(streak: streak, flameColor: color);
                    }),
                  ),
              ],
            ),
          ),
        ],
      ),

      // BODY
      body: CustomScrollView(
        slivers: [

          // CALENDAR HEATMAP
          if (_showCalendar)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: HeatmapSection(groups: groups, habits: habits),
              ),
            ),

          // DIVIDER
          const SliverToBoxAdapter(
            child: Divider(color: MyConstants.lightBlack, indent: 10, endIndent: 10),
          ),

          // LIST OF HABITS
          SliverList(
            delegate: SliverChildBuilderDelegate((ctx, i) {
              final h = groupHabits[i];
              final done = _isDoneToday(h);
              return PeblHabitTile(
                habit: h,
                groupColor: Color(selectedGroup.colorValue),
                isDoneToday: done,
                onToggle: () => _onToggleHabit(h),
                onLongPress: () => HabitDialogs.showEditHabitDialog(context, h),
              );
            }, childCount: groupHabits.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      // BOTTOM NAVBAR
      bottomNavigationBar: PeblBottomNavbar(
        groups: groups,
        currentIndex: _selectedGroupIndex,
        onGroupTap: (i) => setState(() => _selectedGroupIndex = i),
        onGroupLongPress: (i) {
          GroupDialogs.showEdit(context, groups[i], () {
            setState(() => _selectedGroupIndex = 0);
          });
        },
        onAddGroup: () {
          GroupDialogs.showAdd(context, () {});
        },
      ),
    );
  }
}
