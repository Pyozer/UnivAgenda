import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';

class SplashScreen extends StatelessWidget {
  void _initPreferences(BuildContext context) async {
    final prefs = PreferencesProvider.of(context);

    // Load preferences from disk
    await prefs.initFromDisk();

    // Load ressources
    Data.allData = prefs.ressources;

    final bool isFirstBoot = prefs.isFirstBoot;
    final bool isUserLogged = prefs.isUserLogged;

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
