import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';

class SplashScreen extends StatelessWidget {
  Future<Map<String, bool>> _initPreferences(BuildContext context) async {
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

    return {"isFirstBoot": isFirstBoot, "isLogged": isUserLogged};
  }

  @override
  Widget build(BuildContext context) {
    _initPreferences(context).then((data) async {
      final routeDest = (data["isFirstBoot"])
          ? RouteKey.INTRO
          : (data["isLogged"]) ? RouteKey.HOME : RouteKey.LOGIN;
      Future.delayed(Duration(milliseconds: 100)).then((_) {
        Navigator.of(context).pushNamed(routeDest);
      });
    });

    return Container(
      color: Colors.white,
      child: Center(
        child: Hero(
          tag: Asset.LOGO,
          child: Image.asset(Asset.LOGO, width: 175.0),
        ),
      ),
    );
  }
}
