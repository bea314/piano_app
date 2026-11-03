import 'package:flutter/material.dart';

/// Cohesive visual identity for PIANO by EU DE (no external assets).
abstract final class PianoTheme {
  static const Color background = Color(0xFF14110F);
  static const Color surface = Color(0xFF221C18);
  static const Color accent = Color(0xFFC9A962);
  static const Color accentMuted = Color(0xFF8A7344);
  static const Color ivory = Color(0xFFF5F0E6);
  static const Color keyBorder = Color(0xFF3D3630);

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      surface: surface,
      primary: accent,
      onPrimary: background,
      onSurface: ivory,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: ivory,
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          color: ivory,
        ),
      ),
      iconTheme: const IconThemeData(color: accent),
      textTheme: const TextTheme(
        labelSmall: TextStyle(color: accentMuted, letterSpacing: 0.4),
        bodySmall: TextStyle(color: ivory),
      ),
    );
  }
}
