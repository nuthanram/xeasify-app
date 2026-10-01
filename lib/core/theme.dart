import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);

ThemeData xeasifyTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBlack,
    canvasColor: kBlack,
    cardColor: kBlack,
    colorScheme: const ColorScheme.dark(
      primary: kWhite,
      onPrimary: kBlack,
      secondary: kWhite,
      onSecondary: kBlack,
      surface: kBlack,
      onSurface: kWhite,
      error: kWhite,
      onError: kBlack,
      outline: kWhite,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kBlack,
      foregroundColor: kWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.jetBrainsMono(
          color: kWhite,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.5),
      iconTheme: const IconThemeData(color: kWhite, size: 20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kWhite,
        foregroundColor: kBlack,
        textStyle: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 2),
        shape: const RoundedRectangleBorder(),
        minimumSize: const Size(double.infinity, 50),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kWhite,
        side: const BorderSide(color: kWhite, width: 1),
        textStyle: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 2),
        shape: const RoundedRectangleBorder(),
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kWhite,
        textStyle: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1),
        shape: const RoundedRectangleBorder(),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kWhite, width: 1)),
      enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kWhite, width: 1)),
      focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kWhite, width: 2)),
      errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kWhite, width: 1)),
      focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: kWhite, width: 2)),
      labelStyle: GoogleFonts.jetBrainsMono(
          color: kWhite, fontSize: 11, letterSpacing: 1.5),
      hintStyle: GoogleFonts.jetBrainsMono(
          color: kWhite, fontSize: 13, fontStyle: FontStyle.italic),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      floatingLabelStyle: GoogleFonts.jetBrainsMono(
          color: kWhite, fontSize: 10, letterSpacing: 1.5),
      errorStyle: GoogleFonts.jetBrainsMono(color: kWhite, fontSize: 11),
    ),
    dividerColor: kWhite,
    dividerTheme:
        const DividerThemeData(color: kWhite, thickness: 1, space: 1),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kBlack : kWhite),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kWhite : kBlack),
      trackOutlineColor: WidgetStateProperty.all(kWhite),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kWhite : kBlack),
      checkColor: WidgetStateProperty.all(kBlack),
      side: const BorderSide(color: kWhite, width: 1.5),
      shape: const RoundedRectangleBorder(),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: kWhite),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kBlack,
      selectedItemColor: kWhite,
      unselectedItemColor: kWhite,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
          fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1),
      unselectedLabelStyle: TextStyle(fontSize: 9, letterSpacing: 1),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kWhite,
      contentTextStyle:
          GoogleFonts.jetBrainsMono(color: kBlack, fontSize: 12),
      shape: const RoundedRectangleBorder(),
      behavior: SnackBarBehavior.floating,
    ),
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(ThemeData.dark().textTheme)
        .apply(bodyColor: kWhite, displayColor: kWhite),
  );
}
