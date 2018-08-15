import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/widgets/ui/circular_loader.dart';

class SplashScreen extends StatelessWidget {
  Future<bool> _initPreferences(BuildContext context) async {
    String campus = await Preferences.getCampus();
    String department = await Preferences.getDepartment();
    String year = await Preferences.getYear();
    String group = await Preferences.getGroup();

    Preferences.changeGroupPref(
        campus: campus, department: department, year: year, group: group);

    bool isDark = await Preferences.getDarkTheme();
    if (isDark == null) isDark = PrefKey.defaultDarkTheme;

    int appbarColor = await Preferences.getAppbarColor();
    if (appbarColor == null) appbarColor = PrefKey.defaultAppbarColor;

    DynamicTheme.of(context).changeTheme(
        primaryColor: Color(appbarColor), brightness: getBrightness(isDark));

    int numberWeeks = await Preferences.getNumberWeek();
    if (numberWeeks == null)
      await Preferences.setNumberWeek(PrefKey.defaultNumberWeek);

    int noteColor = await Preferences.getNoteColor();
    if (noteColor == null)
      await Preferences.setNoteColor(PrefKey.defaultNoteColor);

    bool isFirstBoot = await Preferences.isFirstBoot();

    await Future.delayed(Duration(seconds: 1), null);
    return isFirstBoot;
  }

  @override
  Widget build(BuildContext context) {
    _initPreferences(context).then((isFirstBoot) {
      final routeDest = (isFirstBoot) ? RouteKey.INTRO : RouteKey.HOME;
      Navigator.of(context).pushReplacementNamed(routeDest);
    });

    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.asset(Asset.LOGO, width: 150.0),
      Padding(
        padding: const EdgeInsets.only(top: 90.0),
        child: const CircularLoader(),
      )
    ])));
  }
}
