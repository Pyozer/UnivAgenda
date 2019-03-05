import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myagenda/app.dart';
import 'package:flutter/foundation.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';

Future<List<int>> loadDefaultData() async {
  var byteData = await rootBundle.load('res/2018g.tzf');
  return byteData.buffer.asUint8List();
}

void main() async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

  initializeDatabase(await loadDefaultData());
  setLocalLocation(getLocation('Europe/Paris'));

  await i18n.init();

  final prefs = await SharedPreferences.getInstance();

  runApp(App(prefs: prefs));
}
