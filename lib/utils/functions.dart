import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

bool isNumeric(String s) {
  return int.tryParse(s) != null;
}

Brightness getBrightness(bool isDark) {
  return isDark ? Brightness.dark : Brightness.light;
}

void openLink(String href) async {
  if (await canLaunch(href))
    await launch(href);
  else
    throw 'Could not launch $href';
}
