import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';

class SplashScreen extends StatelessWidget {
  Future<bool> _initPreferences(BuildContext context) async {
    // Get all data to setup theme
    final bool isDark = await Preferences.getDarkTheme();
    final int appbarColor = await Preferences.getPrimaryColor();
    final int accentColor = await Preferences.getAccentColor();

    // Change theme
    DynamicTheme.of(context).changeTheme(
        primaryColor: Color(appbarColor),
        accentColor: Color(accentColor),
        brightness: getBrightness(isDark));

    // Get groups prefs
    final String campus = await Preferences.getCampus();
    final String department = await Preferences.getDepartment();
    final String year = await Preferences.getYear();
    final String group = await Preferences.getGroup();

    // Check group prefs
    Preferences.changeGroupPref(
        campus: campus, department: department, year: year, group: group);

    final bool isFirstBoot = await Preferences.isFirstBoot();

    return isFirstBoot;
  }

  @override
  Widget build(BuildContext context) {
    _initPreferences(context).then((isFirstBoot) {
      final routeDest = (isFirstBoot) ? RouteKey.INTRO : RouteKey.HOME;
      Navigator.of(context).pushReplacementNamed(routeDest);
    });

    return Container();
  }
}
