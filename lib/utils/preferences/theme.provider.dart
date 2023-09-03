import 'dart:async';

import 'package:flutter/material.dart';

import '../../keys/pref_key.dart';
import 'base.provider.dart';

class ThemeProvider extends BaseProvider {
  ///
  /// Singleton Factory
  ///
  static final instance = ThemeProvider._internal();
  ThemeProvider._internal();

  ThemeMode _themeMode = PrefKey.defaultThemeMode;
  Color _primaryColor = PrefKey.defaultPrimaryColor;
  Color _accentColor = PrefKey.defaultAccentColor;
  Color _noteColor = PrefKey.defaultNoteColor;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode? themeMode, [bool state = false]) {
    if (_themeMode == themeMode) return;

    updatePref(() {
      _themeMode = themeMode ?? PrefKey.defaultThemeMode;
    }, state);
    setString(PrefKey.themeMode, themeMode?.name);
  }

  void setThemeModeFromString(String? themeModeStr, [bool state = false]) {
    ThemeMode themeMode = ThemeMode.values.firstWhere(
      (t) => t.name == themeModeStr,
      orElse: () => ThemeMode.system,
    );
    setThemeMode(themeMode, state);
  }

  Color get primaryColor => _primaryColor;

  void setPrimaryColor(Color? newPrimaryColor, [bool state = false]) {
    if (_primaryColor == newPrimaryColor) return;

    updatePref(() {
      _primaryColor = newPrimaryColor ?? PrefKey.defaultPrimaryColor;
    }, state);
    setInt(PrefKey.primaryColor, _primaryColor.value);
  }

  Color get accentColor => _accentColor;

  void setAccentColor(Color? newAccentColor, [bool state = false]) {
    if (_accentColor == newAccentColor) return;

    updatePref(() {
      _accentColor = newAccentColor ?? PrefKey.defaultAccentColor;
    }, state);
    setInt(PrefKey.accentColor, _accentColor.value);
  }

  Color get noteColor => _noteColor;

  void setNoteColor(Color? newNoteColor, [bool state = false]) {
    if (_noteColor == newNoteColor) return;

    updatePref(() {
      _noteColor = newNoteColor ?? PrefKey.defaultNoteColor;
    }, state);
    setInt(PrefKey.noteColor, _noteColor.value);
  }

  @override
  Future<void> initFromDisk() async {
    final themeMode = sharedPrefs?.getString(PrefKey.themeMode);
    setThemeModeFromString(themeMode);

    final primaryColorValue = sharedPrefs?.getInt(PrefKey.primaryColor);
    if (primaryColorValue != null) setPrimaryColor(Color(primaryColorValue));

    final accentColorValue = sharedPrefs?.getInt(PrefKey.accentColor);
    if (accentColorValue != null) setAccentColor(Color(accentColorValue));

    final noteColorValue = sharedPrefs?.getInt(PrefKey.noteColor);
    if (noteColorValue != null) setNoteColor(Color(noteColorValue));
  }

  @override
  bool operator ==(Object other) =>
      other is ThemeProvider &&
      themeMode == other.themeMode &&
      primaryColor == other.primaryColor &&
      accentColor == other.accentColor &&
      noteColor == other.noteColor;

  @override
  int get hashCode =>
      themeMode.hashCode ^
      primaryColor.hashCode ^
      accentColor.hashCode ^
      noteColor.hashCode;
}
