import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/habit_group.dart';

typedef OnGroupTap = void Function(int index);
typedef OnAddGroup = VoidCallback;
typedef OnGroupLongPress = void Function(int index);

class PeblBottomNavbar extends StatelessWidget {
  final List<HabitGroup> groups;
  final int currentIndex;
  final OnGroupTap onGroupTap;
  final OnAddGroup onAddGroup;
  final OnGroupLongPress onGroupLongPress;

  const PeblBottomNavbar({
    super.key,
    required this.groups,
    required this.currentIndex,
    required this.onGroupTap,
    required this.onAddGroup,
    required this.onGroupLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...List.generate(groups.length, (j) {
                    final group = groups[j];
                    final isSelected = currentIndex == j;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => onGroupTap(j),
                        onLongPress: () => onGroupLongPress(j),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(group.colorValue).withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(group.colorValue)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(group.colorValue),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              Text(
                                group.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? MyConstants.textColor
                                      : MyConstants.mutedTextColor,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: onAddGroup,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: MyConstants.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.add, size: 16, color: MyConstants.accentColor),
                            SizedBox(width: 6),
                            Text(
                              'New Habit Group',
                              style: TextStyle(
                                color: MyConstants.accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
