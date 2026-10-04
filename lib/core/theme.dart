import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Light, high-contrast theme: kBg is the page background (and the text colour on
// filled controls), kFg is text, borders and filled controls.
const Color kBg = Color(0xFFFFFFFF);
const Color kFg = Color(0xFF000000);

ThemeData xeasifyTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: kBg,
    canvasColor: kBg,
    cardColor: kBg,
    colorScheme: const ColorScheme.light(
      primary: kFg,
      onPrimary: kBg,
      secondary: kFg,
      onSecondary: kBg,
      surface: kBg,
      onSurface: kFg,
      error: kFg,
      onError: kBg,
      outline: kFg,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kBg,
      foregroundColor: kFg,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.jetBrainsMono(
          color: kFg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.5),
      iconTheme: const IconThemeData(color: kFg, size: 20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kFg,
        foregroundColor: kBg,
        textStyle: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 2),
        shape: const RoundedRectangleBorder(),
        minimumSize: const Size(double.infinity, 50),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kFg,
        side: const BorderSide(color: kFg, width: 1),
        textStyle: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 2),
        shape: const RoundedRectangleBorder(),
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kFg,
        textStyle: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1),
        shape: const RoundedRectangleBorder(),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kFg, width: 1)),
      enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kFg, width: 1)),
      focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kFg, width: 2)),
      errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kFg, width: 1)),
      focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kFg, width: 2)),
      labelStyle: GoogleFonts.jetBrainsMono(
          color: kFg, fontSize: 11, letterSpacing: 1.5),
      hintStyle: GoogleFonts.jetBrainsMono(
          color: kFg, fontSize: 13, fontStyle: FontStyle.italic),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      floatingLabelStyle: GoogleFonts.jetBrainsMono(
          color: kFg, fontSize: 10, letterSpacing: 1.5),
      errorStyle: GoogleFonts.jetBrainsMono(color: kFg, fontSize: 11),
    ),
    dividerColor: kFg,
    dividerTheme:
        const DividerThemeData(color: kFg, thickness: 1, space: 1),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kBg : kFg),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kFg : kBg),
      trackOutlineColor: WidgetStateProperty.all(kFg),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kFg : kBg),
      checkColor: WidgetStateProperty.all(kBg),
      side: const BorderSide(color: kFg, width: 1.5),
      shape: const RoundedRectangleBorder(),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: kFg),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kBg,
      selectedItemColor: kFg,
      unselectedItemColor: kFg,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
          fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1),
      unselectedLabelStyle: TextStyle(fontSize: 9, letterSpacing: 1),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kFg,
      contentTextStyle:
          GoogleFonts.jetBrainsMono(color: kBg, fontSize: 12),
      shape: const RoundedRectangleBorder(),
      behavior: SnackBarBehavior.floating,
    ),
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(ThemeData.light().textTheme)
        .apply(bodyColor: kFg, displayColor: kFg),
  );
}
