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
    // Get all data to setup theme
    bool isDark = await Preferences.getDarkTheme();
    if (isDark == null) isDark = PrefKey.defaultDarkTheme;

    int appbarColor = await Preferences.getPrimaryColor();
    if (appbarColor == null) appbarColor = PrefKey.defaultPrimaryColor;

    int accentColor = await Preferences.getPrimaryColor();
    if (accentColor == null) accentColor = PrefKey.defaultAccentColor;

    // Change theme
    DynamicTheme.of(context).changeTheme(
        primaryColor: Color(appbarColor),
        accentColor: Color(accentColor),
        brightness: getBrightness(isDark));

    // Get groups prefs
    String campus = await Preferences.getCampus();
    String department = await Preferences.getDepartment();
    String year = await Preferences.getYear();
    String group = await Preferences.getGroup();

    // Check group prefs
    Preferences.changeGroupPref(
        campus: campus, department: department, year: year, group: group);

    // Check other prefs
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
