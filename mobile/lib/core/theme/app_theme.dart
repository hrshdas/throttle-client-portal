import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Palette ────────────────────────────────────────────────
  /// Very clean, cool-light background — like a slightly elevated white surface
  static const Color background    = Color(0xFFF2F2F7);
  static const Color card          = Color(0xFFFFFFFF);
  static const Color primaryText   = Color(0xFF0D0D0D);
  static const Color secondaryText = Color(0xFF6C6C70);
  static const Color tertiaryText  = Color(0xFFAEAEB2);
  static const Color divider       = Color(0xFFF0F0F0);
  static const Color taskCircle    = Color(0xFFD8D8DC);
  static const Color searchAccent  = Color(0xFF7B61FF);

  // ── Card Shadows ─────────────────────────────────────────────────
  /// Layered shadow — ambient (large, soft) + key (small, defined)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.07),
          blurRadius: 28,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.04),
          blurRadius: 8,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get navShadow => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.14),
          blurRadius: 40,
          spreadRadius: -4,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.07),
          blurRadius: 12,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primaryText,
        surface: background,
        onSurface: primaryText,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: primaryText,
        displayColor: primaryText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }
}
