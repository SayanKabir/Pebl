import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/habit.dart';

class PeblHabitTile extends StatefulWidget {
  final Habit habit;
  final Color groupColor;
  final bool isDoneToday;
  final VoidCallback onToggle;
  final VoidCallback? onLongPress;

  const PeblHabitTile({
    super.key,
    required this.habit,
    required this.groupColor,
    required this.isDoneToday,
    required this.onToggle,
    this.onLongPress,
  });

  @override
  State<PeblHabitTile> createState() => _PeblHabitTileState();
}

class _PeblHabitTileState extends State<PeblHabitTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_controller);
    if (widget.isDoneToday) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant PeblHabitTile oldW) {
    super.didUpdateWidget(oldW);
    if (!oldW.isDoneToday && widget.isDoneToday) {
      _controller.forward(from: 0);
    } else if (oldW.isDoneToday && !widget.isDoneToday) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: MyConstants.secondaryBackgroundColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            widget.habit.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.isDoneToday
                  ? MyConstants.textColor.withOpacity(0.4)
                  : MyConstants.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
