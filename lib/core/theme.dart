import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kNeon = Color(0xFF39FF14);
const Color kGray900 = Color(0xFF0A0A0A);
const Color kGray800 = Color(0xFF141414);
const Color kGray700 = Color(0xFF1F1F1F);
const Color kGray600 = Color(0xFF2A2A2A);
const Color kGray500 = Color(0xFF404040);
const Color kGray400 = Color(0xFF666666);
const Color kGray300 = Color(0xFF999999);

ThemeData xeasifyTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: kBlack,
    canvasColor: kBlack,
    cardColor: kGray900,
    colorScheme: const ColorScheme.dark(
      primary: kWhite,
      onPrimary: kBlack,
      secondary: kGray600,
      onSecondary: kWhite,
      surface: kGray900,
      onSurface: kWhite,
      error: kGray400,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBlack,
      foregroundColor: kWhite,
      elevation: 0,
      titleTextStyle: TextStyle(color: kWhite, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.2),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kWhite,
        foregroundColor: kBlack,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        minimumSize: const Size(double.infinity, 46),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kWhite,
        side: const BorderSide(color: kGray600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        minimumSize: const Size(double.infinity, 46),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kGray900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: kGray700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: kGray700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: kWhite),
      ),
      labelStyle: const TextStyle(color: kGray400, fontSize: 12),
      hintStyle: const TextStyle(color: kGray500, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    dividerColor: kGray800,
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(base.textTheme).apply(
      bodyColor: kWhite,
      displayColor: kWhite,
    ),
  );
}
