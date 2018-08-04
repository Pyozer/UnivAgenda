import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/models/pref_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Widget ThemedWidgetBuilder(BuildContext context, ThemeData data);

class DynamicTheme extends StatefulWidget {
  final ThemedWidgetBuilder themedWidgetBuilder;
  final ThemeData defaultTheme;

  const DynamicTheme({Key key, this.themedWidgetBuilder, this.defaultTheme})
      : super(key: key);

  @override
  DynamicThemeState createState() => new DynamicThemeState();

  static DynamicThemeState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<DynamicThemeState>());
  }
}

class DynamicThemeState extends State<DynamicTheme> {
  ThemeData _theme;

  @override
  void initState() {
    super.initState();
    _theme = widget.defaultTheme;

    _loadTheme().then((theme) {
      _updateTheme(theme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.themedWidgetBuilder(context, _theme);
  }

  void changeTheme({Brightness brightness, Color primaryColor}) {
    ThemeData updatedTheme =
        _editTheme(brightness: brightness, primaryColor: primaryColor);
    _updateTheme(updatedTheme);
    _saveTheme();
  }

  ThemeData _editTheme({Brightness brightness, Color primaryColor}) {
    return ThemeData(
        brightness: brightness ?? _theme.brightness,
        primaryColor: primaryColor ?? _theme.primaryColor,
        accentColor: primaryColor ?? _theme.accentColor);
  }

  void _updateTheme(ThemeData updatedTheme) {
    setState(() {
      this._theme = updatedTheme;
    });
  }

  ThemeData get theme => _theme;

  Future<ThemeData> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isDark = prefs.getBool(PrefKey.DARK_THEME) ?? false;
    Brightness brightness = isDark ? Brightness.dark : Brightness.light;
    Color primaryColor =
        Color(prefs.getInt(PrefKey.APPBAR_COLOR) ?? 0xFF000000);

    return _editTheme(brightness: brightness, primaryColor: primaryColor);
  }

  Future _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKey.DARK_THEME,
        _theme.brightness == Brightness.dark ? true : false);
    await prefs.setInt(PrefKey.APPBAR_COLOR, _theme.primaryColor.value);
  }
}
