import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:http/http.dart' as http;

const resourcesUrl =
    "https://rawcdn.githack.com/Pyozer/MyAgenda_Flutter/master/res/resources.json";

class SplashScreen extends StatefulWidget {
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initPreferences();
  }

  Future<Null> _initPreferences() async {
    bool hasInternet = false;

    // Check if internet is available
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasInternet = true;
      }
    } on SocketException catch (_) {
      hasInternet = false;
    }

    final prefs = PreferencesProvider.of(context);

    // Update resources if internet available
    if (hasInternet) {
      try {
        final response = await http.get(resourcesUrl);
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          Map<String, dynamic> ressources = json.decode(response.body);
          prefs.setResources(ressources, false);
        }
      } catch (_) {}
    }
    // Send resources to Data
    Data.allData = prefs.resources;

    // Load preferences from disk
    await prefs.initFromDisk();

    final bool isFirstBoot = prefs.isFirstBoot;
    final bool isUserLogged = prefs.isUserLogged;

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
