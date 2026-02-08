import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../services/notification_service.dart';
import 'glass_container.dart';

class HabitDialogs {
  static void showAddHabitDialog(BuildContext context, String groupId) {
    final provider = context.read<HabitProvider>();
    final txtName = TextEditingController();
    bool enableReminder = false;
    TimeOfDay? reminderTime;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: StatefulBuilder(
            builder: (ctx, setState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add Habit',
                      style: TextStyle(
                          color: MyConstants.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  
                  // Habit name
                  TextField(
                    controller: txtName,
                    autofocus: true,
                    style: const TextStyle(color: MyConstants.textColor),
                    decoration: const InputDecoration(
                      labelText: 'Habit name',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Reminder toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Set reminder',
                          style: TextStyle(color: MyConstants.textColor)),
                      Switch(
                        value: enableReminder,
                        onChanged: (val) async {
                          if (val) {
                            // Request permissions first
                            await NotificationService().requestAllPermissions();
                          }
                          setState(() => enableReminder = val);
                        },
                        activeColor: Colors.teal,
                      ),
                    ],
                  ),
                  
                  // Reminder time picker
                  if (enableReminder) ...[
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: reminderTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => reminderTime = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              reminderTime != null
                                  ? reminderTime!.format(context)
                                  : 'Select time',
                              style: TextStyle(
                                color: reminderTime != null
                                    ? MyConstants.textColor
                                    : Colors.white54,
                              ),
                            ),
                            const Icon(Icons.access_time, color: Colors.white54),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
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
                            final nm = txtName.text.trim();
                            if (nm.isNotEmpty) {
                              DateTime? reminderDateTime;
                              if (enableReminder && reminderTime != null) {
                                final now = DateTime.now();
                                reminderDateTime = DateTime(
                                  now.year, now.month, now.day,
                                  reminderTime!.hour, reminderTime!.minute,
                                );
                              }
                              
                              provider.addHabit(
                                nm,
                                groupId,
                                reminderTime: reminderDateTime,
                              );
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
        ),
      ),
    );
  }

  static void showEditHabitDialog(BuildContext context, Habit habit) {
    final provider = context.read<HabitProvider>();
    final txtName = TextEditingController(text: habit.name);
    bool enableReminder = habit.reminderTime != null;
    TimeOfDay? reminderTime = habit.reminderTime != null
        ? TimeOfDay(hour: habit.reminderTime!.hour, minute: habit.reminderTime!.minute)
        : null;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: StatefulBuilder(
            builder: (ctx, setState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Edit Habit',
                      style: TextStyle(
                          color: MyConstants.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  
                  // Habit name
                  TextField(
                    controller: txtName,
                    autofocus: true,
                    style: const TextStyle(color: MyConstants.textColor),
                    decoration: const InputDecoration(
                      labelText: 'Habit name',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Reminder toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Set reminder',
                          style: TextStyle(color: MyConstants.textColor)),
                      Switch(
                        value: enableReminder,
                        onChanged: (val) async {
                          if (val) {
                            await NotificationService().requestAllPermissions();
                          }
                          setState(() {
                            enableReminder = val;
                            if (!val) reminderTime = null;
                          });
                        },
                        activeColor: Colors.teal,
                      ),
                    ],
                  ),
                  
                  // Reminder time picker
                  if (enableReminder) ...[
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: reminderTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => reminderTime = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              reminderTime != null
                                  ? reminderTime!.format(context)
                                  : 'Select time',
                              style: TextStyle(
                                color: reminderTime != null
                                    ? MyConstants.textColor
                                    : Colors.white54,
                              ),
                            ),
                            const Icon(Icons.access_time, color: Colors.white54),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
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
                            final nm = txtName.text.trim();
                            if (nm.isNotEmpty) {
                              DateTime? reminderDateTime;
                              if (enableReminder && reminderTime != null) {
                                final now = DateTime.now();
                                reminderDateTime = DateTime(
                                  now.year, now.month, now.day,
                                  reminderTime!.hour, reminderTime!.minute,
                                );
                              }
                              
                              provider.editHabit(
                                habit,
                                nm,
                                reminderTime: reminderDateTime,
                                clearReminder: !enableReminder,
                              );
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
        ),
      ),
    );
  }
}