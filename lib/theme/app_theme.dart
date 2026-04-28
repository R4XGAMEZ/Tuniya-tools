import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color purple = Color(0xFF7B2FBE);
  static const Color red = Color(0xFFE8003D);
  static const Color darkBg = Color(0xFF0A0A0F);
  static const Color cardBg = Color(0xFF13131C);
  static const Color cardBg2 = Color(0xFF1A1A27);
  static const Color borderColor = Color(0xFF2A2A3D);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0CC);
  static const Color textMuted = Color(0xFF606080);

  static LinearGradient get brandGradient => const LinearGradient(
        colors: [purple, red],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get bgGradient => const LinearGradient(
        colors: [Color(0xFF0A0A0F), Color(0xFF0F0A1A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        primaryColor: purple,
        colorScheme: const ColorScheme.dark(
          primary: purple,
          secondary: red,
          surface: cardBg,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimary,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.orbitron(
            color: textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          displayMedium: GoogleFonts.orbitron(
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          displaySmall: GoogleFonts.orbitron(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          headlineMedium: GoogleFonts.rajdhani(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: GoogleFonts.rajdhani(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: GoogleFonts.rajdhani(
            color: textPrimary,
            fontSize: 16,
          ),
          bodyMedium: GoogleFonts.rajdhani(
            color: textSecondary,
            fontSize: 14,
          ),
          bodySmall: GoogleFonts.rajdhani(
            color: textSecondary,
            fontSize: 12,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkBg,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.orbitron(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        cardTheme: CardTheme(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borderColor, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.rajdhani(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardBg2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: purple, width: 2),
          ),
          hintStyle: GoogleFonts.rajdhani(color: textSecondary, fontSize: 14),
          labelStyle: GoogleFonts.rajdhani(color: textSecondary, fontSize: 14),
        ),
        dividerColor: borderColor,
        iconTheme: const IconThemeData(color: textSecondary, size: 22),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: cardBg,
          selectedItemColor: purple,
          unselectedItemColor: textSecondary,
          showUnselectedLabels: true,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: cardBg2,
          contentTextStyle: GoogleFonts.rajdhani(color: textPrimary, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
