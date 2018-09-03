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

void openLink(String href) async {
  if (await canLaunch(href))
    await launch(href);
  else
    throw 'Could not launch $href';
}

String twoDigits(int number) {
  return number.toString().padLeft(2, '0');
}

String capitalize(String input) {
  if (input == null) throw new ArgumentError("string: $input");
  if (input.length == 0) return input;
  if (input.length == 1) return input[0].toUpperCase();

  return input[0].toUpperCase() + input.substring(1);
}

String getStringBetween(String origin, String begin, String end) {
  RegExp pattern = RegExp(begin + "(.+?)" + end);
  Match matcher = pattern.firstMatch(origin);
  if (matcher.groupCount > 0)
    return matcher.group(1);
  else
    return null;
}
