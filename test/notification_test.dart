import 'package:flutter_test/flutter_test.dart';
import 'package:pebl/models/habit.dart';
import 'package:pebl/models/habit_group.dart';

void main() {
  group('Habit Completion Detection', () {
    late Habit testHabit;
    late DateTime today;

    setUp(() {
      today = DateTime.now();
      testHabit = Habit(
        name: 'Test Habit',
        groupId: 'test-group-id',
      );
    });

    test('habit is not completed when completedDates is empty', () {
      expect(testHabit.completedDates, isEmpty);
      expect(_isCompletedToday(testHabit, today), isFalse);
    });

    test('habit is completed when today is in completedDates', () {
      testHabit.completedDates.add(today);
      expect(_isCompletedToday(testHabit, today), isTrue);
    });

    test('habit is not completed when only other dates are in completedDates', () {
      final yesterday = today.subtract(const Duration(days: 1));
      testHabit.completedDates.add(yesterday);
      expect(_isCompletedToday(testHabit, today), isFalse);
    });

    test('habit is completed even with multiple dates including today', () {
      final yesterday = today.subtract(const Duration(days: 1));
      testHabit.completedDates.add(yesterday);
      testHabit.completedDates.add(today);
      expect(_isCompletedToday(testHabit, today), isTrue);
    });
  });

  group('Group Completion Detection', () {
    late DateTime today;
    late List<Habit> habits;
    late HabitGroup group;

    setUp(() {
      today = DateTime.now();
      group = HabitGroup(
        id: 'group-1',
        name: 'Morning Routine',
        colorValue: 0xFF00FF00,
        groupReminderTime: DateTime(today.year, today.month, today.day, 8, 0),
      );
      habits = [
        Habit(name: 'Habit 1', groupId: 'group-1'),
        Habit(name: 'Habit 2', groupId: 'group-1'),
        Habit(name: 'Habit 3', groupId: 'group-1'),
      ];
    });

    test('group is not complete when no habits are done', () {
      expect(_areAllGroupHabitsDone(habits, 'group-1', today), isFalse);
    });

    test('group is not complete when only some habits are done', () {
      habits[0].completedDates.add(today);
      habits[1].completedDates.add(today);
      // habit[2] not done
      expect(_areAllGroupHabitsDone(habits, 'group-1', today), isFalse);
    });

    test('group is complete when all habits are done today', () {
      for (var h in habits) {
        h.completedDates.add(today);
      }
      expect(_areAllGroupHabitsDone(habits, 'group-1', today), isTrue);
    });

    test('group with no habits is not considered complete (empty list edge case)', () {
      final emptyHabits = <Habit>[];
      expect(_areAllGroupHabitsDone(emptyHabits, 'group-1', today), isFalse);
    });

    test('group completion only considers habits in that group', () {
      // Add a habit from a different group
      habits.add(Habit(name: 'Other Habit', groupId: 'different-group'));
      
      // Mark only the group-1 habits as done
      for (var h in habits.where((h) => h.groupId == 'group-1')) {
        h.completedDates.add(today);
      }
      
      expect(_areAllGroupHabitsDone(habits, 'group-1', today), isTrue);
    });
  });

  group('RescheduleAll Skip Logic', () {
    late DateTime today;
    late List<Habit> habits;
    late List<HabitGroup> groups;

    setUp(() {
      today = DateTime.now();
      groups = [
        HabitGroup(
          id: 'group-1',
          name: 'Morning',
          colorValue: 0xFF00FF00,
          groupReminderTime: DateTime(today.year, today.month, today.day, 8, 0),
        ),
        HabitGroup(
          id: 'group-2',
          name: 'Evening',
          colorValue: 0xFF0000FF,
          groupReminderTime: DateTime(today.year, today.month, today.day, 20, 0),
        ),
      ];
      habits = [
        Habit(name: 'Morning 1', groupId: 'group-1'),
        Habit(name: 'Morning 2', groupId: 'group-1'),
        Habit(name: 'Evening 1', groupId: 'group-2'),
      ];
    });

    test('should schedule group when habits are not done', () {
      final groupsToSchedule = _getGroupsToSchedule(groups, habits, today);
      expect(groupsToSchedule, contains('group-1'));
      expect(groupsToSchedule, contains('group-2'));
    });

    test('should skip group when all its habits are done', () {
      // Mark all group-1 habits as done
      for (var h in habits.where((h) => h.groupId == 'group-1')) {
        h.completedDates.add(today);
      }
      
      final groupsToSchedule = _getGroupsToSchedule(groups, habits, today);
      expect(groupsToSchedule, isNot(contains('group-1')));
      expect(groupsToSchedule, contains('group-2'));
    });

    test('should skip all groups when all habits are done', () {
      for (var h in habits) {
        h.completedDates.add(today);
      }
      
      final groupsToSchedule = _getGroupsToSchedule(groups, habits, today);
      expect(groupsToSchedule, isEmpty);
    });

    test('should skip groups without reminder time', () {
      groups.add(HabitGroup(
        id: 'group-no-reminder',
        name: 'No Reminder',
        colorValue: 0xFF000000,
        groupReminderTime: null,
      ));
      habits.add(Habit(name: 'No Reminder Habit', groupId: 'group-no-reminder'));
      
      final groupsToSchedule = _getGroupsToSchedule(groups, habits, today);
      expect(groupsToSchedule, isNot(contains('group-no-reminder')));
    });
  });

  group('Individual Habit Reminder Logic', () {
    late DateTime today;
    late Habit habitWithReminder;
    late Habit habitWithoutReminder;

    setUp(() {
      today = DateTime.now();
      habitWithReminder = Habit(
        name: 'With Reminder',
        groupId: 'test-group',
        reminderTime: DateTime(today.year, today.month, today.day, 9, 0),
      );
      habitWithoutReminder = Habit(
        name: 'Without Reminder',
        groupId: 'test-group',
        reminderTime: null,
      );
    });

    test('habit with reminder should be scheduled when not done', () {
      expect(_shouldScheduleHabitReminder(habitWithReminder, today), isTrue);
    });

    test('habit with reminder should not be scheduled when done today', () {
      habitWithReminder.completedDates.add(today);
      expect(_shouldScheduleHabitReminder(habitWithReminder, today), isFalse);
    });

    test('habit without reminder should never be scheduled', () {
      expect(_shouldScheduleHabitReminder(habitWithoutReminder, today), isFalse);
    });

    test('habit done yesterday should still be scheduled today', () {
      final yesterday = today.subtract(const Duration(days: 1));
      habitWithReminder.completedDates.add(yesterday);
      expect(_shouldScheduleHabitReminder(habitWithReminder, today), isTrue);
    });
  });
}

// Helper functions that mirror the logic in the actual implementation

bool _isCompletedToday(Habit habit, DateTime today) {
  return habit.completedDates.any((d) =>
      d.year == today.year && d.month == today.month && d.day == today.day);
}

bool _areAllGroupHabitsDone(List<Habit> allHabits, String groupId, DateTime today) {
  final groupHabits = allHabits.where((h) => h.groupId == groupId).toList();
  if (groupHabits.isEmpty) return false;
  return groupHabits.every((h) => _isCompletedToday(h, today));
}

List<String> _getGroupsToSchedule(
    List<HabitGroup> groups, List<Habit> habits, DateTime today) {
  final result = <String>[];
  for (var group in groups) {
    if (group.groupReminderTime == null) continue;
    
    final groupHabits = habits.where((h) => h.groupId == group.id).toList();
    final allDoneToday = groupHabits.isNotEmpty && 
        groupHabits.every((h) => _isCompletedToday(h, today));
    
    if (!allDoneToday) {
      result.add(group.id);
    }
  }
  return result;
}

bool _shouldScheduleHabitReminder(Habit habit, DateTime today) {
  if (habit.reminderTime == null) return false;
  return !_isCompletedToday(habit, today);
}
