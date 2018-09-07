import 'package:flutter/material.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';

class SplashScreen extends StatelessWidget {

  void _initPreferences(BuildContext context) async {
    final prefs = PreferencesProvider.of(context).prefs;
    // Get all data to setup theme
    final bool isDark = await prefs.getDarkTheme();
    final int appbarColor = await prefs.getPrimaryColor();
    final int accentColor = await prefs.getAccentColor();

    // Change theme
    DynamicTheme.of(context).changeTheme(
      primaryColor: Color(appbarColor),
      accentColor: Color(accentColor),
      brightness: getBrightness(isDark),
    );

    // Get groups prefs
    final String campus = await prefs.getCampus();
    final String department = await prefs.getDepartment();
    final String year = await prefs.getYear();
    final String group = await prefs.getGroup();

    // Check group prefs
    prefs.changeGroupPref(
        campus: campus, department: department, year: year, group: group);

    final bool isFirstBoot = await prefs.isFirstBoot();
    final bool isUserLogged = await prefs.isUserLogged();

    final routeDest = (isFirstBoot)
        ? RouteKey.INTRO
        : (isUserLogged) ? RouteKey.HOME : RouteKey.LOGIN;

    Navigator.of(context).pushReplacementNamed(routeDest);
  }

  @override
  Widget build(BuildContext context) {
    _initPreferences(context);
    return Container(color: Colors.white);
  }
}