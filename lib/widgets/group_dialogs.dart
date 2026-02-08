import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/habit_group_provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_group.dart';
import '../services/notification_service.dart';
import 'glass_container.dart';

class GroupDialogs {
  /// Shows the "Add Group" dialog and handles adding logic.
  static void showAdd(BuildContext context, VoidCallback onRefresh) {
    final provider = context.read<HabitGroupProvider>();
    final txtName = TextEditingController();
    Color selected = MyConstants.flamePebbleColors[0];
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
                  Text('Add Group',
                      style: TextStyle(
                          color: MyConstants.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  
                  // Group name
                  TextField(
                    controller: txtName,
                    autofocus: true,
                    style: const TextStyle(color: MyConstants.textColor),
                    decoration: const InputDecoration(
                        labelText: 'Group name',
                        labelStyle: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 10),
                  
                  // Color picker
                  Wrap(
                    spacing: 8,
                    children: MyConstants.flamePebbleColors.map((c) {
                      return GestureDetector(
                        onTap: () => setState(() => selected = c),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c,
                            border: Border.all(
                                color: selected == c
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Group reminder toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Set group reminder',
                          style: TextStyle(color: MyConstants.textColor)),
                      Switch(
                        value: enableReminder,
                        onChanged: (val) async {
                          if (val) {
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
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
                                  style:
                                      TextStyle(color: MyConstants.textColor)))),
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
                                  
                                  provider.addGroup(
                                    nm,
                                    selected,
                                    groupReminderTime: reminderDateTime,
                                  );
                                  Navigator.pop(context);
                                  onRefresh();
                                }
                              },
                              child: const Text('Save'))),
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

  /// Shows the "Edit Group" dialog and handles editing/deletion.
  static void showEdit(
      BuildContext context, HabitGroup group, VoidCallback onRefresh) {
    final provider = context.read<HabitGroupProvider>();
    final habitProvider = context.read<HabitProvider>();
    final txtName = TextEditingController(text: group.name);
    Color selected = Color(group.colorValue);
    bool enableReminder = group.groupReminderTime != null;
    TimeOfDay? reminderTime = group.groupReminderTime != null
        ? TimeOfDay(
            hour: group.groupReminderTime!.hour,
            minute: group.groupReminderTime!.minute)
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
                  Text('Edit Group',
                      style: TextStyle(
                          color: MyConstants.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  
                  // Group name
                  TextField(
                    controller: txtName,
                    autofocus: true,
                    style: const TextStyle(color: MyConstants.textColor),
                    decoration: const InputDecoration(
                        labelText: 'Group name',
                        labelStyle: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 10),
                  
                  // Color picker
                  Wrap(
                    spacing: 8,
                    children: MyConstants.flamePebbleColors.map((c) {
                      return GestureDetector(
                        onTap: () => setState(() => selected = c),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c,
                            border: Border.all(
                                color: selected == c
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Group reminder toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Set group reminder',
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
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
                                  style:
                                      TextStyle(color: MyConstants.textColor)))),
                      Expanded(
                          child: TextButton(
                              onPressed: () {
                                provider.deleteGroup(
                                    group.id, habitProvider.deleteHabitsForGroup);
                                Navigator.pop(context);
                                onRefresh();
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)))),
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
                                  
                                  provider.editGroup(
                                    group.id,
                                    nm,
                                    selected,
                                    groupReminderTime: reminderDateTime,
                                    clearReminder: !enableReminder,
                                  );
                                  Navigator.pop(context);
                                  onRefresh();
                                }
                              },
                              child: const Text('Save'))),
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