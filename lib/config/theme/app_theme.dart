import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colores de la app
const Color primaryBlack = Color(0xFF1A1A1A);
const Color primaryYellow = Color(0xFFE8A838);
const Color scaffoldBackgroundColor = Color(0xFFF8F7F7);
const Color inputBackgroundColor = Color(0xFFF5F5F5);

class AppTheme {
  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primaryYellow,

    // Texts
    textTheme: TextTheme(
      titleLarge: GoogleFonts.montserratAlternates().copyWith(
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.montserratAlternates().copyWith(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: GoogleFonts.montserratAlternates().copyWith(fontSize: 20),
      bodyLarge: GoogleFonts.montserratAlternates().copyWith(fontSize: 16),
      bodyMedium: GoogleFonts.montserratAlternates().copyWith(fontSize: 14),
    ),

    // Scaffold Background Color
    scaffoldBackgroundColor: scaffoldBackgroundColor,

    // Buttons
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(primaryBlack),
        foregroundColor: const WidgetStatePropertyAll(primaryYellow),
        minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.montserratAlternates().copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryYellow, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.montserratAlternates().copyWith(
        color: Colors.grey,
        fontSize: 14,
      ),
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBlack,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserratAlternates().copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}
