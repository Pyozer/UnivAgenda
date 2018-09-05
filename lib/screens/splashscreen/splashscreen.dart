import 'package:flutter/material.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  void _initPreferences() async {
    // Get all data to setup theme
    final bool isDark = await Preferences.getDarkTheme();
    final int appbarColor = await Preferences.getPrimaryColor();
    final int accentColor = await Preferences.getAccentColor();

    // Change theme
    DynamicTheme.of(context).changeTheme(
      primaryColor: Color(appbarColor),
      accentColor: Color(accentColor),
      brightness: getBrightness(isDark),
    );

    // Get groups prefs
    final String campus = await Preferences.getCampus();
    final String department = await Preferences.getDepartment();
    final String year = await Preferences.getYear();
    final String group = await Preferences.getGroup();

    // Check group prefs
    Preferences.changeGroupPref(
        campus: campus, department: department, year: year, group: group);

    final bool isFirstBoot = await Preferences.isFirstBoot();
    final bool isUserLogged = await Preferences.isUserLogged();

    final routeDest = (isFirstBoot)
        ? RouteKey.INTRO
        : (isUserLogged) ? RouteKey.HOME : RouteKey.LOGIN;

    Navigator.of(context).pushReplacementNamed(routeDest);
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white);
  }
}