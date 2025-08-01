import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/habit_group_provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_group.dart';
import 'glass_container.dart';

class GroupDialogs {
  /// Shows the "Add Group" dialog and handles adding logic.
  static void showAdd(BuildContext context, VoidCallback onRefresh) {
    final provider = context.read<HabitGroupProvider>();
    final txt = TextEditingController();
    Color selected = MyConstants.flamePebbleColors[0];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: StatefulBuilder(
            builder: (ctx, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add Group', style: TextStyle(color: MyConstants.textColor, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                  controller: txt,
                  autofocus: true,
                  style: const TextStyle(color: MyConstants.textColor),
                  decoration: const InputDecoration(labelText: 'Group name', labelStyle: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 10),
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
                          border: Border.all(color: selected == c ? Colors.white : Colors.transparent, width: 2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: MyConstants.textColor)))),
                    Expanded(child: ElevatedButton(onPressed: () {
                      final nm = txt.text.trim();
                      if (nm.isNotEmpty) {
                        provider.addGroup(nm, selected);
                        Navigator.pop(context);
                        onRefresh();
                      }
                    }, child: const Text('Save'))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows the "Edit Group" dialog and handles editing/deletion.
  static void showEdit(BuildContext context, HabitGroup group, VoidCallback onRefresh) {
    final provider = context.read<HabitGroupProvider>();
    final habitProvider = context.read<HabitProvider>();
    final txt = TextEditingController(text: group.name);
    Color selected = Color(group.colorValue);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: StatefulBuilder(
            builder: (ctx, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Group', style: TextStyle(color: MyConstants.textColor, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                  controller: txt,
                  autofocus: true,
                  style: const TextStyle(color: MyConstants.textColor),
                  decoration: const InputDecoration(labelText: 'Group name', labelStyle: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 10),
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
                          border: Border.all(color: selected == c ? Colors.white : Colors.transparent, width: 2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: MyConstants.textColor)))),
                    Expanded(child: TextButton(onPressed: () {
                      provider.deleteGroup(group.id, habitProvider.deleteHabitsForGroup);
                      Navigator.pop(context);
                      onRefresh();
                    }, child: const Text('Delete', style: TextStyle(color: Colors.red)))),
                    Expanded(child: ElevatedButton(onPressed: () {
                      final nm = txt.text.trim();
                      if (nm.isNotEmpty) {
                        provider.editGroup(group.id, nm, selected);
                        Navigator.pop(context);
                        onRefresh();
                      }
                    }, child: const Text('Save'))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}