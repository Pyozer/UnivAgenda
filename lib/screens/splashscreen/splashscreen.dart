import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/widgets/logo_app.dart';

class SplashScreen extends StatelessWidget {
  Future<bool> _initPreferences(BuildContext context) async {
    String campus = await Preferences.getCampus();
    String department = await Preferences.getDepartment();
    String year = await Preferences.getYear();
    String group = await Preferences.getGroup();

    Preferences.changeGroupPref(
        campus: campus, department: department, year: year, group: group);

    bool isDark = await Preferences.getDarkTheme();
    if (isDark == null) isDark = PrefKey.DEFAULT_DARK_THEME;

    int appbarColor = await Preferences.getAppbarColor();
    if (appbarColor == null) appbarColor = PrefKey.DEFAULT_APPBAR_COLOR;

    DynamicTheme.of(context).changeTheme(
        primaryColor: Color(appbarColor), brightness: getBrightness(isDark));

    int numberWeeks = await Preferences.getNumberWeek();
    if (numberWeeks == null)
      await Preferences.setNumberWeek(PrefKey.DEFAULT_NUMBER_WEEK);

    int noteColor = await Preferences.getNoteColor();
    if (noteColor == null)
      await Preferences.setNoteColor(PrefKey.DEFAULT_NOTE_COLOR);

    bool isFirstBoot = await Preferences.isFirstBoot();
    return isFirstBoot;
  }

  @override
  Widget build(BuildContext context) {
    _initPreferences(context).then((isFirstBoot) {
      if (isFirstBoot)
        Navigator.of(context).pushReplacementNamed(RouteKey.INTRO);
      else
        Navigator.of(context).pushReplacementNamed(RouteKey.HOME);
    });

    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const LogoApp(),
      const Padding(padding: const EdgeInsets.only(top: 100.0)),
      const CircularProgressIndicator(
          strokeWidth: 4.0,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red))
    ])));
  }
}
