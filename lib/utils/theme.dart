import 'package:flutter/material.dart';

import 'functions.dart';

ThemeData generateTheme({
  required Brightness brightness,
  required Color primaryColor,
  required Color accentColor,
}) {
  return ThemeData(
    brightness: brightness,
    fontFamily: 'GoogleSans',
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        backgroundColor: accentColor,
        foregroundColor: getColorDependOfBackground(accentColor),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 6.0,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: getColorDependOfBackground(accentColor),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        foregroundColor: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
  );
}
