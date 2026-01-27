import 'dart:ui'; // Required for BackdropFilter
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
    with TickerProviderStateMixin {
  // Controller for the "Squish" effect on tap
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  // Controller for the "Check" animation (The satisfying part)
  late final AnimationController _checkController;
  late final Animation<double> _iconScaleAnimation;

  // State to track mouse hover
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();

    // 1. Setup Press Animation
    _pressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_pressController);

    // 2. Setup Completion Animation (Elastic Pop)
    _checkController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_checkController);

    if (widget.isDoneToday) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant PeblHabitTile oldW) {
    super.didUpdateWidget(oldW);
    if (!oldW.isDoneToday && widget.isDoneToday) {
      _checkController.forward(from: 0.0);
    } else if (oldW.isDoneToday && !widget.isDoneToday) {
      _checkController.reverse();
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the color based on state
    final Color activeColor = widget.groupColor;
    final Color inactiveBorder = Colors.white.withOpacity(0.1);
    final Color inactiveBg = Colors.white.withOpacity(0.05);

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      onTap: widget.onToggle,
      onLongPress: widget.onLongPress,
      child: MouseRegion(
        // Detect Hover Enter/Exit
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _pressController,
          builder: (_, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  // 1. The Glassmorphic Blur
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),

                  // 2. The Animated Content Container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: widget.isDoneToday
                          ? activeColor.withOpacity(0.25)
                          : (_isHovering 
                              ? Colors.white.withOpacity(0.08) // Slight light up on hover
                              : inactiveBg),
                      border: Border.all(
                        color: widget.isDoneToday
                            ? activeColor.withOpacity(0.6)
                            : (_isHovering 
                                ? Colors.white.withOpacity(0.2) // Brighter border on hover
                                : inactiveBorder),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Row(
                      children: [
                        _buildAnimatedCheckbox(activeColor),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: widget.isDoneToday ? 0.6 : 1.0,
                            child: Text(
                              widget.habit.name,
                              style: TextStyle(
                                color: MyConstants.textColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                decoration: widget.isDoneToday
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                decorationColor: activeColor,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildAnimatedCheckbox(Color color) {
    return Container(
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isDoneToday ? color : Colors.transparent,
        border: Border.all(
          color: widget.isDoneToday
              ? color
              : (_isHovering 
                  ? Colors.white.withOpacity(0.5) // Brighter ring on hover
                  : Colors.white.withOpacity(0.3)),
          width: 2,
        ),
      ),
      child: Center(
        child: widget.isDoneToday
            ? ScaleTransition(
                scale: _iconScaleAnimation,
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              )
            : AnimatedOpacity(
                // Show a "Ghost" tick when hovering, but not done
                duration: const Duration(milliseconds: 200),
                opacity: _isHovering ? 1.0 : 0.0,
                child: Icon(
                  Icons.check_rounded,
                  // The ghost tick uses the group color but semi-transparent
                  color: color.withOpacity(0.5), 
                  size: 18,
                ),
              ),
      ),
    );
  }
}