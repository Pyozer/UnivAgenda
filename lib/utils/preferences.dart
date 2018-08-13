import 'dart:async';

import 'package:myagenda/data.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/models/prefs_calendar.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<String> getCampus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.campus);
  }

  static Future<String> getDepartment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.department);
  }

  static Future<String> getYear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.year);
  }

  static Future<String> getGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.group);
  }

  static Future<PrefsCalendar> changeGroupPref(
      {String campus, String department, String year, String group}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    PrefsCalendar values = Data.checkDataValues(
        campus: campus, department: department, year: year, group: group);

    await prefs.setString(PrefKey.campus, values.campus);
    await prefs.setString(PrefKey.department, values.department);
    await prefs.setString(PrefKey.year, values.year);
    await prefs.setString(PrefKey.group, values.group);

    return values;
  }

  static Future<int> getNumberWeek() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.numberWeek);
  }

  static Future<int> setNumberWeekStr(String numberWeek) async {
    int intValue = PrefKey.defaultNumberWeek;
    if (isNumeric(numberWeek)) intValue = int.parse(numberWeek);
    return setNumberWeek(intValue);
  }

  static Future<int> setNumberWeek(int numberWeek) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.numberWeek, numberWeek);
    return numberWeek;
  }

  static Future<bool> getDarkTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKey.darkTheme);
  }

  static Future<bool> setDarkTheme(bool darkTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKey.darkTheme, darkTheme);
    return darkTheme;
  }

  static Future<int> getAppbarColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.appbarColor);
  }

  static Future<int> setAppbarColor(int appbarColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.appbarColor, appbarColor);
    return appbarColor;
  }

  static Future<int> getNoteColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKey.noteColor);
  }

  static Future<int> setNoteColor(int noteColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKey.noteColor, noteColor);
    return noteColor;
  }

  static Future<bool> isFirstBoot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKey.firstBoot) ?? true;
  }

  static Future<bool> setFirstBoot(bool isFirstBoot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKey.firstBoot, isFirstBoot);
    return isFirstBoot;
  }

  static Future<String> getCachedIcal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKey.cachedIcal) ?? null;
  }

  static Future<String> setCachedIcal(String icalToCache) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKey.cachedIcal, icalToCache);
    return icalToCache;
  }

  static Future<Map<String, dynamic>> getAllValues() async {
    Map<String, dynamic> dataPrefs = {};
    dataPrefs[PrefKey.campus] = await Preferences.getCampus();
    dataPrefs[PrefKey.department] = await Preferences.getDepartment();
    dataPrefs[PrefKey.year] = await Preferences.getYear();
    dataPrefs[PrefKey.group] = await Preferences.getGroup();
    dataPrefs[PrefKey.numberWeek] = await Preferences.getNumberWeek();
    dataPrefs[PrefKey.darkTheme] = await Preferences.getDarkTheme();
    dataPrefs[PrefKey.appbarColor] = await Preferences.getAppbarColor();
    dataPrefs[PrefKey.noteColor] = await Preferences.getNoteColor();

    return dataPrefs;
  }
}
