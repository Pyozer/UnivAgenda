import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
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

Color createColorFromText(String text) {
  var hash = 0;
  for (var i = 0; i < text.length; i++) {
    hash = text.codeUnitAt(i) + ((hash << 5) - hash);
  }
  var c = (hash & 0x00FFFFFF).toRadixString(16).toUpperCase();

  String colorHexStr = "00000".substring(0, 6 - c.length) + c;
  return Color(int.parse("0xFF$colorHexStr"));
}

Color getColorFromString(String string) {
  var sum = 0;
  for (var i = 0; i < string.length; i++) {
    sum += string.codeUnitAt(i);
  }
  int colorIndex = sum % materialColors.length;

  return materialColors[colorIndex];
}
