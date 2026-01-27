import 'dart:math';
import 'dart:ui';
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
import 'package:flutter_animate/flutter_animate.dart';

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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF353A40), // Deep Onyx
            Color(0xFF161719), // Midnight
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,

        // APPBAR
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: MyConstants.mediumBlack.withValues(alpha: 0.5),
              ),
            ),
          ),

          // LOGO
          title: Container(
            width: 120, height: 80,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/pebl2.png'), fit: BoxFit.contain),
            ),
          ),
          actions: [
            // SHOW/HIDE HEATMAP BUTTON
            IconButton(
              icon: Icon(_showCalendar ? Icons.expand_less : Icons.expand_more, color: Colors.white),
              onPressed: () => setState(() => _showCalendar = !_showCalendar),
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
            SliverToBoxAdapter(child: SizedBox(height: 120)), // Use larger spacer for larger AppBar

          // CALENDAR HEATMAP
          if (_showCalendar)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: HeatmapSection(groups: groups, habits: habits),
                    ),
                  ),
                ),
              ).animate().fade(duration: 600.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
            ),

          // DIVIDER
          const SliverToBoxAdapter(
            child: Divider(color: MyConstants.lightBlack, indent: 10, endIndent: 10),
          ),

          // LIST OF HABITS
          if (groupHabits.isEmpty)
             const SliverToBoxAdapter(
               child: Padding(
                 padding: EdgeInsets.only(top: 50.0),
                 child: Center(
                   child: Text(
                     "No habits yet",
                     style: TextStyle(color: MyConstants.mutedTextColor, fontSize: 16),
                   ),
                 ),
               ),
             ),

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
              ).animate().fade(duration: 400.ms, delay: (50 * i).ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
            }, childCount: groupHabits.length),
          ),

          // ADD HABIT BUTTON (Glassmorphic)
          SliverToBoxAdapter(
            child: UnconstrainedBox(
              child: GestureDetector(
                onTap: () => HabitDialogs.showAddHabitDialog(context, selectedGroup.id),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  height: 50,
                  width: 200, // Fixed width for smaller button
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30), // More rounded pill shape
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: MyConstants.textColor.withValues(alpha: 0.9), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "add habit",
                              style: TextStyle(
                                color: MyConstants.textColor.withValues(alpha: 0.9),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().shimmer(delay: 2.seconds, duration: 1.seconds, color: Colors.white24),
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
      ),
    );
  }
}
