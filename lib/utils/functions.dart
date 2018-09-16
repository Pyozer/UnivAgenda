import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

bool isNumeric(String s) {
  return int.tryParse(s) != null;
}

Brightness getBrightness(bool isDark) {
  return isDark ? Brightness.dark : Brightness.light;
}

bool isDarkTheme(Brightness brightness) {
  return brightness == Brightness.dark;
}

Future<void> openLink(String href) async {
  if (await canLaunch(href))
    await launch(href);
  else
    throw 'Could not launch $href';
}

String capitalize(String input) {
  if (input == null) throw new ArgumentError("string: $input");
  if (input.length == 0) return input;
  if (input.length == 1) return input[0].toUpperCase();

  return input[0].toUpperCase() + input.substring(1);
}