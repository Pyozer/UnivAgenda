import 'package:flutter/material.dart';

import 'functions.dart';

ThemeData generateTheme({
  required Brightness brightness,
  required Color primaryColor,
  required Color accentColor,
}) {
  final isDark = brightness == Brightness.dark;

  return ThemeData(
    brightness: brightness,
    fontFamily: 'GoogleSans',
    useMaterial3: true,
    //colorSchemeSeed: accentColor,
    colorScheme: ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
      primaryContainer: primaryColor,
      outline: accentColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        backgroundColor: isDark ? null : primaryColor,
        foregroundColor:
            isDark ? null : getColorDependOfBackground(primaryColor),
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
    // appBarTheme: AppBarTheme(
    //   backgroundColor: primaryColor,
    //   foregroundColor: getColorDependOfBackground(primaryColor),
    // ),
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
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
    ),
    dialogTheme: DialogTheme(
      actionsPadding: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
  );
}
