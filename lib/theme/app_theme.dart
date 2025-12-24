import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryLight = Colors.lightBlue;
  static const Color primaryDark = Colors.blue;
  static const Color primaryLight50 = Color(0xFFE0F7FA);
  static const Color primaryLight100 = Color(0xFFB3E5FC);
  static const Color primaryLight400 = Color(0xFF29B6F6);
  static const Color accent = Colors.orange;
  static const Color accentDark = Color(0xFFF57C00);

  // Status Colors
  static const Color success = Colors.green;
  static const Color warning = Colors.amber;
  static const Color danger = Colors.red;
  static const Color info = Colors.blue;
  static const Color infoDark = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFF64B5F6);

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color black87 = Colors.black87;
  static const Color black54 = Colors.black54;
  static const Color grey = Colors.grey;
  static const Color greyLight = Color(0xFFEEEEEE);

  // Semantic Colors
  static Color get scaffoldBackground => Colors.grey.shade100;
  static Color get cardBackground => Colors.white;
  static Color get textPrimary => Colors.black87;
  static Color get textSecondary => Colors.black54;
  static Color get inputFill => Colors.blue.shade50;
  static Color get inputBorder => Colors.blue.shade50;
  static Color get divider => Colors.grey;

  // Button Colors
  static Color get buttonPrimary => Colors.lightBlue.shade600;
  static Color get buttonPrimaryDark => Colors.blue.shade700;
  static Color get buttonText => Colors.white;

  // Gradients
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [Colors.blue.shade700, Colors.lightBlue.shade400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status color mapping for report review statuses
  static Color getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('evacuate')) return accentDark;
    if (s.contains('discard')) return success;
    if (s.contains('watch')) return warning;
    if (s.contains('monitor')) return info;
    return grey;
  }

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.lightBlue.shade600,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.blue.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
