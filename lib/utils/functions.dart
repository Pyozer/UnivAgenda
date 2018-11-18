import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

bool isNumeric(String s) => int.tryParse(s) != null;

Brightness getBrightness(bool isDark) =>
    isDark ? Brightness.dark : Brightness.light;

bool isDarkTheme(Brightness brightness) => brightness == Brightness.dark;

Future<void> openLink(BuildContext ctx, String href, String analytic) async {
  if (await canLaunch(href)) {
    await launch(href);
  } else {
    Scaffold.of(ctx).showSnackBar(
      SnackBar(content: Text('Could not launch $href')),
    );
  }
  if (ctx != null && analytic != null)
    AnalyticsProvider.of(ctx).sendLinkClicked(analytic);
}

String capitalize(String input) {
  if (input == null) throw ArgumentError("string: $input");
  if (input.length == 0) return input;
  if (input.length == 1) return input[0].toUpperCase();

  return input[0].toUpperCase() + input.substring(1);
}

Color createColorFromText(String text) {
  var hash = 0;
  text.split('').forEach((char) {
    hash = char.codeUnitAt(0) + ((hash << 5) - hash);
  });
  final c = (hash & 0x00FFFFFF).toRadixString(16).toUpperCase();

  String colorHexStr = "00000".substring(0, 6 - c.length) + c;
  return Color(int.parse("0xFF$colorHexStr"));
}

Color getColorFromString(String string) {
  List<Color> colors = [];
  for (MaterialColor colorSwatch in materialColors)
    for (int i = 400; i < 800; i += 200) colors.add(colorSwatch[i]);

  var sum = 0;
  string.codeUnits.forEach((code) => sum += code);

  return colors[sum % materialColors.length];
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

bool listEquals(List a, List b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;

  for (int i = 0; i < a.length; i++) if (a[i] != b[i]) return false;
  return true;
}

bool listEqualsNotOrdered(List a, List b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;

  for (var i = 0; i < a.length; i++) if (b.indexOf(a[i]) == -1) return false;

  return true;
}
