import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Palette — deep obsidian with electric accents
  static const Color background = Color(0xFF080C10);
  static const Color surface = Color(0xFF0E1318);
  static const Color surfaceElevated = Color(0xFF141B22);
  static const Color border = Color(0xFF1E2A35);

  static const Color eyeOpen = Color(0xFF00E57A);    // Electric green
  static const Color eyeOpenGlow = Color(0xFF00FF88);
  static const Color eyeClosed = Color(0xFFFF3B5C);  // Neon red
  static const Color eyeClosedGlow = Color(0xFFFF1744);

  static const Color textPrimary = Color(0xFFECF0F4);
  static const Color textSecondary = Color(0xFF6B7F8E);
  static const Color textMuted = Color(0xFF3A4E5C);

  static const Color accent = Color(0xFF00CFFF);     // Cyan highlight

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        secondary: eyeOpen,
        error: eyeClosed,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textSecondary),
          bodyMedium: TextStyle(color: textMuted),
        ),
      ),
      useMaterial3: true,
    );
  }
}
