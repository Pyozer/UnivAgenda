import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myagenda/app.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<List<int>> loadDefaultData() async {
  var byteData = await rootBundle.load('packages/timezone/data/2019a_all.tzf');
  return byteData.buffer.asUint8List();
}

void main() async {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  // Init timezone
  initializeDatabase(await loadDefaultData());
  setLocalLocation(getLocation(await FlutterNativeTimezone.getLocalTimezone()));
  // Init translations
  await i18n.init();
  // Init shared preferences
  final prefs = await SharedPreferences.getInstance();

  runApp(App(prefs: prefs));
}
