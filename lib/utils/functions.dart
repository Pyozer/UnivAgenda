import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:path_provider/path_provider.dart';
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

Future<void> openLink(
  BuildContext context,
  String href,
  String analyticsValue,
) async {
  if (await canLaunch(href))
    await launch(href);
  else
    throw 'Could not launch $href';
  if (context != null && analyticsValue != null)
    AnalyticsProvider.of(context).sendLinkClicked(analyticsValue);
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
  List<Color> colors = [];
  for (int i = 400; i < 800; i += 200)
    for (MaterialColor colorSwatch in materialColors)
      colors.add(colorSwatch[i]);

  var sum = 0;
  for (var i = 0; i < string.length; i++) {
    sum += string.codeUnitAt(i);
  }
  int colorIndex = sum % materialColors.length;

  return colors[colorIndex];
}

Future<String> readFile(String filename, String defaultValue) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return await File('$path/$filename')?.readAsString() ?? defaultValue;
  } catch (_) {
    return defaultValue;
  }
}

Future<void> writeFile(String filename, dynamic content) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    await File('$path/$filename')?.writeAsString(content);
  } catch (_) {}

  return;
}
