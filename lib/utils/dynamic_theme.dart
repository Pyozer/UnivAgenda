import 'dart:async';

import 'package:color_picker/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';

typedef Widget ThemedWidgetBuilder(BuildContext context, ThemeData data);

class DynamicTheme extends StatefulWidget {
  final ThemedWidgetBuilder themedWidgetBuilder;
  final ThemeData defaultTheme;

  const DynamicTheme({Key key, this.themedWidgetBuilder, this.defaultTheme})
      : super(key: key);

  @override
  DynamicThemeState createState() => DynamicThemeState();

  static DynamicThemeState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<DynamicThemeState>());
  }
}

class DynamicThemeState extends State<DynamicTheme> {
  ThemeData _theme;

  @override
  void initState() {
    super.initState();
    _updateTheme(widget.defaultTheme);

    _loadTheme().then((theme) {
      _updateTheme(theme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.themedWidgetBuilder(context, _theme);
  }

  void changeTheme(
      {Brightness brightness, Color primaryColor, Color accentColor}) {
    final updatedTheme = _buildTheme(
        brightness: brightness,
        primaryColor: primaryColor,
        accentColor: accentColor);
    _updateTheme(updatedTheme);
    _saveTheme();
  }

  ThemeData _buildTheme(
      {Brightness brightness, Color primaryColor, Color accentColor}) {
    final primarySwatch = _findMainColor(primaryColor);

    return ThemeData(
        fontFamily: _theme.textTheme.title.fontFamily,
        brightness: brightness ?? _theme.brightness,
        primarySwatch: primarySwatch,
        primaryColor: primaryColor ?? _theme.primaryColor,
        accentColor: accentColor ?? _theme.accentColor);
  }

  void _updateTheme(ThemeData updatedTheme) {
    setState(() {
      this._theme = updatedTheme;
    });
  }

  Future<ThemeData> _loadTheme() async {
    Brightness brightness = widget.defaultTheme.brightness;
    Color primaryColor = widget.defaultTheme.primaryColor;
    Color accentColor = widget.defaultTheme.accentColor;

    bool isDark = await Preferences.getDarkTheme();
    if (isDark != null) brightness = getBrightness(isDark);

    int primaryColorValue = await Preferences.getPrimaryColor();
    if (primaryColorValue != null) primaryColor = Color(primaryColorValue);

    int accentColorValue = await Preferences.getAccentColor();
    if (accentColorValue != null) accentColor = Color(accentColorValue);

    return _buildTheme(
        brightness: brightness,
        primaryColor: primaryColor,
        accentColor: accentColor);
  }

  Future _saveTheme() async {
    await Preferences
        .setDarkTheme(_theme.brightness == Brightness.dark ? true : false);
    await Preferences.setPrimaryColor(_theme.primaryColor.value);
    await Preferences.setAccentColor(_theme.accentColor.value);
  }

  ThemeData get theme => _theme;

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
