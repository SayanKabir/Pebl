import 'dart:ui';

class MyConstants {
  // Core Blacks and Grays
  static const pureBlack = Color(0xFF000000);
  static const semiBlack = Color(0xFF0F0F10);  // Background tone
  static const mediumBlack = Color(0xFF262626); // Cards, surfaces
  static const lightBlack = Color(0xFF2C2C2E);  // Elevated surfaces

  // Backgrounds
  static const backgroundColor = Color(0xFF0F0F10); // Main app background
  static const secondaryBackgroundColor = Color(0xFF1A1A1C); // Card or sheet background

  // Text Colors
  static const textColor = Color(0xFFF5F5F5);       // Main text (off-white)
  static const mutedTextColor = Color(0xFF888888);  // Subtext or labels
  static const dividerColor = Color(0xFF2A2A2E);     // Thin line separators

  // Accent (pebble glow reflection)
  static const accentColor = Color(0xFFFFD9A0); // Warm glow (light peach)

  // Pebble tones adapted for dark background
  static const pebbleLight = Color(0xFFD0C9C2); // Light highlight
  static const pebbleMedium = Color(0xFF9A948D); // Midtone
  static const pebbleDark = Color(0xFF5E5A56);  // Dark side
  static const pebbleShadow = Color(0xFF1B1B1B); // Pebble shadow

  static const flamePebbleColors = [
    Color(0xFF6A8CAF), // Dusty Slate Blue
    Color(0xFF7AA89F), // Muted Teal Green
    Color(0xFFE0A96D), // Soft Burnt Amber
    Color(0xFFC46A6A), // Gentle Ember Rose
    Color(0xFF8C72B5), // Soft Lavender Violet (replaces Warm Pebble Taupe)
  ];
}
