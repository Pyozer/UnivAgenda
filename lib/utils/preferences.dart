import 'dart:async';

import 'package:myagenda/data.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/models/prefs_calendar.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<String> getCampus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.CAMPUS);
  }

  static Future<String> getDepartment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.DEPARTMENT);
  }

  static Future<String> getYear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.YEAR);
  }

  static Future<String> getGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.GROUP);
  }

  static Future<PrefsCalendar> changeGroupPref(
      {String campus, String department, String year, String group}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    PrefsCalendar values = Data.checkDataValues(
        campus: campus, department: department, year: year, group: group);

    await prefs.setString(PrefKey.CAMPUS, values.campus);
    await prefs.setString(PrefKey.DEPARTMENT, values.department);
    await prefs.setString(PrefKey.YEAR, values.year);
    await prefs.setString(PrefKey.GROUP, values.group);

    return values;
  }

  static Future<int> getNumberWeek() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.NUMBER_WEEK);
  }

  static Future<int> setNumberWeekStr(String numberWeek) async {
    int intValue = PrefKey.DEFAULT_NUMBER_WEEK;
    if (isNumeric(numberWeek)) intValue = int.parse(numberWeek);
    return setNumberWeek(intValue);
  }

  static Future<int> setNumberWeek(int numberWeek) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.NUMBER_WEEK, numberWeek);
    return numberWeek;
  }

  static Future<bool> getDarkTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKey.DARK_THEME);
  }

  static Future<bool> setDarkTheme(bool darkTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKey.DARK_THEME, darkTheme);
    return darkTheme;
  }

  static Future<int> getAppbarColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.APPBAR_COLOR);
  }

  static Future<int> setAppbarColor(int appbarColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.APPBAR_COLOR, appbarColor);
    return appbarColor;
  }

  static Future<int> getNoteColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.NOTE_COLOR);
  }

  static Future<int> setNoteColor(int noteColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.NOTE_COLOR, noteColor);
    return noteColor;
  }

  static Future<bool> isFirstBoot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKey.FIRST_BOOT) ?? true;
  }

  static Future<bool> setFirstBoot(bool isFirstBoot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKey.FIRST_BOOT, isFirstBoot);
    return isFirstBoot;
  }

  static Future<Map<String, dynamic>> getAllValues() async {
    Map<String, dynamic> dataPrefs = {};
    dataPrefs[PrefKey.CAMPUS] = await Preferences.getCampus();
    dataPrefs[PrefKey.DEPARTMENT] = await Preferences.getDepartment();
    dataPrefs[PrefKey.YEAR] = await Preferences.getYear();
    dataPrefs[PrefKey.GROUP] = await Preferences.getGroup();
    dataPrefs[PrefKey.NUMBER_WEEK] = await Preferences.getNumberWeek();
    dataPrefs[PrefKey.DARK_THEME] = await Preferences.getDarkTheme();
    dataPrefs[PrefKey.APPBAR_COLOR] = await Preferences.getAppbarColor();
    dataPrefs[PrefKey.NOTE_COLOR] = await Preferences.getNoteColor();

    return dataPrefs;
  }
}
