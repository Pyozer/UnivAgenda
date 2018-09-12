import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:http/http.dart' as http;

const resourcesUrl =
    "https://rawgit.com/Pyozer/MyAgenda_Flutter/master/res/resources.json";

class SplashScreen extends StatefulWidget {
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool _isPrefsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initPreferences();
  }

  Future<Null> _initPreferences() async {
    final startTime = DateTime.now();

    final prefs = PreferencesProvider.of(context);

    if (!_isPrefsLoaded) {
      // Update resources if they are older than 12 hours
      if (prefs.resourcesDate.difference(DateTime.now()).inHours >= 12) {
        try {
          final response = await http.get(resourcesUrl);
          if (response.statusCode == 200 && response.body.isNotEmpty) {
            Map<String, dynamic> ressources = json.decode(response.body);
            prefs.setResources(ressources, false);
            prefs.setResourcesDate(startTime);
          }
        } catch (_) {}
      }

      // Load preferences from disk
      await prefs.initFromDisk();

      _isPrefsLoaded = true;
    }

    final bool isFirstBoot = prefs.isFirstBoot;
    final bool isUserLogged = prefs.isUserLogged;

    final routeDest = (isFirstBoot)
        ? RouteKey.INTRO
        : (isUserLogged) ? RouteKey.HOME : RouteKey.LOGIN;

    // Wait minimum 1 seconde
    final endTime = DateTime.now();
    final diffMs = endTime.difference(startTime).inMilliseconds;
 
    await Future.delayed(
      Duration(milliseconds: diffMs < 1500 ? 1500 - diffMs : 0),
    );

    Navigator.of(context).pushReplacementNamed(routeDest);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: <Widget>[
          const Expanded(
            flex: 1,
            child: const SizedBox.shrink(),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Image.asset(Asset.LOGO, width: 192.0),
            ),
          ),
          const Expanded(
            flex: 1,
            child: const Center(
              child: const CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
