import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';

typedef Widget ThemedWidgetBuilder(BuildContext context, ThemeData data);

class DynamicTheme extends StatelessWidget {
  final ThemedWidgetBuilder themedWidgetBuilder;

  const DynamicTheme({
    Key key,
    this.themedWidgetBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prefs = PreferencesProvider.of(context);
    return themedWidgetBuilder(
      context,
      _buildTheme(
        brightness: getBrightness(prefs.theme.darkTheme),
        primaryColor: Color(prefs.theme.primaryColor),
        accentColor: Color(prefs.theme.accentColor),
      ),
    );
  }

  ThemeData _buildTheme({
    Brightness brightness,
    Color primaryColor,
    Color accentColor,
  }) {
    return ThemeData(
        fontFamily: 'GoogleSans',
        brightness: brightness,
        primarySwatch: _findMainColor(primaryColor),
        primaryColor: primaryColor,
        accentColor: accentColor);
  }

  MaterialColor _findMainColor(Color shadeColor) {
    if (shadeColor == null) return null;

    for (final mainColor in materialColors)
      if (_isShadeOfMain(mainColor, shadeColor)) return mainColor;

    return null;
  }

  bool _isShadeOfMain(MaterialColor mainColor, Color shadeColor) {
    List<Color> shades = [
      mainColor.shade50,
      mainColor.shade100,
      mainColor.shade200,
      mainColor.shade300,
      mainColor.shade400,
      mainColor.shade500,
      mainColor.shade600,
      mainColor.shade700,
      mainColor.shade800,
      mainColor.shade900,
    ];
    for (var shade in shades) if (shade == shadeColor) return true;
    return false;
  }
}
