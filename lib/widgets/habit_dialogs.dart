import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import 'glass_container.dart';

class HabitDialogs {
  static void showAddHabitDialog(BuildContext context, String groupId) {
    final provider = context.read<HabitProvider>();
    final txt = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Habit',
                  style: TextStyle(
                      color: MyConstants.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: txt,
                autofocus: true,
                style: const TextStyle(color: MyConstants.textColor),
                decoration: const InputDecoration(
                  labelText: 'Habit name',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: MyConstants.textColor)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final nm = txt.text.trim();
                        if (nm.isNotEmpty) {
                          provider.addHabit(nm, groupId);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showEditHabitDialog(BuildContext context, Habit habit) {
    final provider = context.read<HabitProvider>();
    final txt = TextEditingController(text: habit.name);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Habit',
                  style: TextStyle(
                      color: MyConstants.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: txt,
                autofocus: true,
                style: const TextStyle(color: MyConstants.textColor),
                decoration: const InputDecoration(
                  labelText: 'Habit name',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: MyConstants.textColor)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        provider.deleteHabit(habit);
                        Navigator.pop(context);
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final nm = txt.text.trim();
                        if (nm.isNotEmpty) {
                          provider.editHabit(habit, nm);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}