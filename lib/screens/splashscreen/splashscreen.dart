import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/preferences.dart';

const resourcesUrl =
    "https://raw.githubusercontent.com/Pyozer/MyAgenda_Flutter/master/res/resources.json";

class SplashScreen extends StatefulWidget {
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool _isPrefsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrefsLoaded) {
      _initPreferences();
    }
  }

  void _initPreferences() async {
    _isPrefsLoaded = true;

    final startTime = DateTime.now();

    final prefs = PreferencesProvider.of(context);

    // Update resources if they are older than 12 hours
    if (prefs.resourcesDate.difference(DateTime.now()).inHours >= 12) {
      try {
        final response = await HttpRequest.get(resourcesUrl);
        if (response.isSuccess) {
          Map<String, dynamic> ressources = json.decode(response.httpResponse.body);
          prefs.setResources(ressources, false);
          prefs.setResourcesDate(startTime);
        }
      } catch (_) {}
    }

    // Load preferences from disk
    prefs.initFromDisk(true).then((_) {
      final routeDest = (prefs.isFirstBoot)
          ? RouteKey.INTRO
          : (prefs.isUserLogged) ? RouteKey.HOME : RouteKey.LOGIN;

      // Wait minimum 1.5 secondes
      final diffMs = DateTime.now().difference(startTime).inMilliseconds;
      final waitTime = diffMs < 1500 ? 1500 - diffMs : 0;

      Future.delayed(Duration(milliseconds: waitTime)).then((_) {
        _goToNext(routeDest);
      });
    });
  }

  void _goToNext(String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      body: Column(
        mainAxisSize: MainAxisSize.max,
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
