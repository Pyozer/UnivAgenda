import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/models/pref_key.dart';
import 'package:myagenda/models/prefs_calendar.dart';
import 'package:myagenda/widgets/logo_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  Future _initPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getKeys().forEach((key) {
      prefs.remove(key);
    });

    String campus = prefs.getString(PrefKey.CAMPUS);
    String department = prefs.getString(PrefKey.DEPARTMENT);
    String year = prefs.getString(PrefKey.YEAR);
    String group = prefs.getString(PrefKey.GROUP);

    PrefsCalendar values = Data.checkDataValues(
        campus: campus, department: department, year: year, group: group);

    await prefs.setString(PrefKey.CAMPUS, values.campus);
    await prefs.setString(PrefKey.DEPARTMENT, values.department);
    await prefs.setString(PrefKey.YEAR, values.year);
    await prefs.setString(PrefKey.GROUP, values.group);

    bool isDark = prefs.getBool(PrefKey.DARK_THEME);
    if (isDark == null)
      await prefs.setBool(PrefKey.DARK_THEME, PrefKey.DEFAULT_DARK_THEME);

    int numberWeeks = prefs.getInt(PrefKey.NUMBER_WEEK);
    if (numberWeeks == null)
      await prefs.setInt(PrefKey.NUMBER_WEEK, PrefKey.DEFAULT_NUMBER_WEEK);

    int appbarColor = prefs.getInt(PrefKey.APPBAR_COLOR);
    if (appbarColor == null)
      await prefs.setInt(PrefKey.APPBAR_COLOR, PrefKey.DEFAULT_APPBAR_COLOR);

    int noteColor = prefs.getInt(PrefKey.NOTE_COLOR);
    if (noteColor == null)
      await prefs.setInt(PrefKey.NOTE_COLOR, PrefKey.DEFAULT_NOTE_COLOR);

    return null;
  }

  _startTime(BuildContext context) async {
    var _duration = Duration(milliseconds: 1500);
    return Timer(
        _duration, () => Navigator.of(context).pushReplacementNamed('/'));
  }

  @override
  Widget build(BuildContext context) {
    _initPreferences().then((finish) {
      _startTime(context);
    });

    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      LogoApp(),
      const Padding(padding: EdgeInsets.only(top: 100.0)),
      const CircularProgressIndicator(
          strokeWidth: 4.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red))
    ])));
  }
}
