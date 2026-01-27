import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final Color flameColor;

  const StreakBadge({
    super.key,
    required this.streak,
    required this.flameColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      width: 25,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            FontAwesomeIcons.fire,
            size: 25,
            color: flameColor,
          ),

          // Always Bordered number inside icon
          Positioned(
            bottom: -4,
            child: Stack(
              children: [
                // Border
                Text(
                  '$streak',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3
                      ..color = Colors.black,
                  ),
                ),

                // Fill
                Text(
                  '$streak',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
