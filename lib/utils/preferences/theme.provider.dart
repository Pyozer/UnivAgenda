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

  bool _darkTheme = PrefKey.defaultDarkTheme;
  Color _primaryColor = PrefKey.defaultPrimaryColor;
  Color _accentColor = PrefKey.defaultAccentColor;
  Color _noteColor = PrefKey.defaultNoteColor;

  Brightness get brightness => this._darkTheme ? Brightness.dark : Brightness.light;

  bool get darkTheme => _darkTheme;

  void setDarkTheme(bool? darkTheme, [bool state = false]) {
    if (_darkTheme == darkTheme) return;

    updatePref(() {
      _darkTheme = darkTheme ?? PrefKey.defaultDarkTheme;
    }, state);
    setBool(PrefKey.isDarkTheme, darkTheme);
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

  Future<void> initFromDisk(BuildContext context, [bool state = false]) async {
    final isDarkTheme = sharedPrefs?.getBool(PrefKey.isDarkTheme);
    final deviceBrightness = MediaQuery.of(context).platformBrightness;
    setDarkTheme(isDarkTheme ?? deviceBrightness == Brightness.dark);

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
          darkTheme == other.darkTheme &&
          primaryColor == other.primaryColor &&
          accentColor == other.accentColor &&
          noteColor == other.noteColor;

  @override
  int get hashCode =>
      darkTheme.hashCode ^
      primaryColor.hashCode ^
      accentColor.hashCode ^
      noteColor.hashCode;
}
