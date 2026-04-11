import 'package:flutter/material.dart';

/// FitNova App Theme
/// Deep violet + Electric cyan color palette with dark mode first
class AppTheme {
  // ── Brand Colors ─────────────────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF6C63FF);       // Deep violet
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF4A43CC);
  static const Color accentColor = Color(0xFF00D4FF);        // Electric cyan
  static const Color accentGreen = Color(0xFF00E5A0);        // Neon green
  static const Color accentOrange = Color(0xFFFF6B35);       // Energy orange
  static const Color accentPink = Color(0xFFFF4D8D);         // Hot pink

  // ── Dark Theme Colors ─────────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0E0E1A);             // Main background
  static const Color darkSurface = Color(0xFF1A1A2E);        // Card background
  static const Color darkSurface2 = Color(0xFF252540);       // Elevated surfaces
  static const Color darkBorder = Color(0xFF2E2E50);         // Borders
  static const Color darkText = Color(0xFFE8E8FF);           // Primary text
  static const Color darkTextMuted = Color(0xFF8888AA);      // Secondary text

  // ── Light Theme Colors ────────────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF5F5FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A2E);

  // ── Gradient Presets ──────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E35), Color(0xFF252545)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00E5A0), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Dark Theme ────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: darkSurface,
        background: darkBg,
        onPrimary: Colors.white,
        onSecondary: darkBg,
        onSurface: darkText,
        onBackground: darkText,
        error: Color(0xFFFF4D4D),
      ),
      fontFamily: 'Poppins',
      textTheme: _buildTextTheme(darkText, darkTextMuted),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        iconTheme: IconThemeData(color: darkText),
      ),
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(color: darkTextMuted, fontFamily: 'Poppins'),
        labelStyle: const TextStyle(color: darkTextMuted, fontFamily: 'Poppins'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkTextMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurface2,
        contentTextStyle: const TextStyle(color: darkText, fontFamily: 'Poppins'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: lightSurface,
        background: lightBg,
        onPrimary: Colors.white,
        onSurface: lightText,
        onBackground: lightText,
      ),
      fontFamily: 'Poppins',
      textTheme: _buildTextTheme(lightText, Colors.grey),
    );
  }

  // ── Text Theme Builder ────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
      bodyLarge: TextStyle(fontSize: 16, color: primary),
      bodyMedium: TextStyle(fontSize: 14, color: primary),
      bodySmall: TextStyle(fontSize: 12, color: secondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
    );
  }
}
