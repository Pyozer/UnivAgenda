import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/custom_route.dart';
import 'package:univagenda/utils/list_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

extension BuildContextExt on BuildContext {
  get isDark {
    return Theme.of(this).brightness == Brightness.dark;
  }
}

Color getColorDependOfBackground(
  Color bgColor, {
  Color? ifLight,
  Color? ifDark,
}) {
  return (ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark)
      ? ifDark ?? Colors.white
      : ifLight ?? Colors.black;
}

Future<void> openLink(
  BuildContext? context,
  String href,
  String? analytic,
) async {
  if (await canLaunchUrlString(href)) {
    await launchUrlString(href);
  } else if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not launch $href')),
    );
  }
  if (analytic != null) AnalyticsProvider.sendLinkClicked(analytic);
}

String capitalize(String? input) {
  if (input == null) throw ArgumentError("string: $input");
  if (input.isEmpty) return input;
  if (input.length == 1) return input[0].toUpperCase();

  return input[0].toUpperCase() + input.substring(1);
}

Color getColorFromString(String string) {
  List<Color> colors = [];
  for (ColorSwatch colorSwatch in appMaterialColors)
    for (int i = 400; i < 800; i += 200) {
      if (colorSwatch[i] != null) colors.add(colorSwatch[i]!);
    }

  int sum = 0;
  string.codeUnits.forEach((code) => sum += code);

  return colors[sum % appMaterialColors.length];
}

Future<String> readFile(String filename, String defaultValue) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$filename').readAsString();
  } catch (_) {
    return defaultValue;
  }
}

Future<void> writeFile(String filename, dynamic content) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    await File('$path/$filename').writeAsString(content);
  } catch (_) {}
}

bool listEqualsNotOrdered(List? a, List? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;

  for (var i = 0; i < a.length; i++) if (b.indexOf(a[i]) == -1) return false;

  return true;
}

Future<T?> navigatorPush<T>(
  BuildContext context,
  Widget screen, {
  bool fullscreenDialog = false,
}) {
  return Navigator.push(
    context,
    CustomRoute<T>(builder: (_) => screen, fullscreenDialog: fullscreenDialog),
  );
}

Future<T?> navigatorPushReplace<T>(
  BuildContext context,
  Widget screen, {
  bool fullscreenDialog = false,
}) {
  return Navigator.pushAndRemoveUntil(
    context,
    CustomRoute<T>(builder: (_) => screen, fullscreenDialog: fullscreenDialog),
    (_) => false,
  );
}

Future<T?> navigatorPopAndPush<T>(
  BuildContext context,
  Widget screen, {
  bool fullscreenDialog = false,
}) {
  Navigator.of(context).pop();
  return Navigator.push(
    context,
    CustomRoute<T>(builder: (_) => screen, fullscreenDialog: fullscreenDialog),
  );
}
