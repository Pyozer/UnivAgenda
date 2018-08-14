import 'dart:async';

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

  void changeTheme({Brightness brightness, Color primaryColor}) {
    final updatedTheme =
        _buildTheme(brightness: brightness, primaryColor: primaryColor);
    _updateTheme(updatedTheme);
    _saveTheme();
  }

  ThemeData _buildTheme({Brightness brightness, Color primaryColor}) {
    return ThemeData(
        fontFamily: _theme.textTheme.title.fontFamily,
        brightness: brightness ?? _theme.brightness,
        primaryColor: primaryColor ?? _theme.primaryColor,
        accentColor: primaryColor ?? _theme.accentColor);
  }

  void _updateTheme(ThemeData updatedTheme) {
    setState(() {
      this._theme = updatedTheme;
    });
  }

  Future<ThemeData> _loadTheme() async {
    Brightness brightness = widget.defaultTheme.brightness;
    Color primaryColor = widget.defaultTheme.primaryColor;

    bool isDark = await Preferences.getDarkTheme();
    if (isDark != null) brightness = getBrightness(isDark);

    int primaryColorValue = await Preferences.getAppbarColor();
    if (primaryColorValue != null) primaryColor = Color(primaryColorValue);

    return _buildTheme(brightness: brightness, primaryColor: primaryColor);
  }

  Future _saveTheme() async {
    await Preferences
        .setDarkTheme(_theme.brightness == Brightness.dark ? true : false);
    await Preferences.setAppbarColor(_theme.primaryColor.value);
  }

  ThemeData get theme => _theme;
}
