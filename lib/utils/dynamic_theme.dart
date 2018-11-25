import 'package:flutter/material.dart';
import 'package:myagenda/utils/list_colors.dart';

typedef Widget ThemedWidgetBuilder(BuildContext context, ThemeData data);

class DynamicTheme extends StatelessWidget {
  final ThemedWidgetBuilder themedWidgetBuilder;
  final ThemeData theme;

  const DynamicTheme({
    Key key,
    @required this.theme,
    @required this.themedWidgetBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return themedWidgetBuilder(
      context,
      ThemeData(
        fontFamily: theme.textTheme.display1.fontFamily,
        canvasColor: theme.canvasColor,
        brightness: theme.brightness,
        primarySwatch: _findMainColor(theme.primaryColor),
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        toggleableActiveColor: theme.accentColor,
        textSelectionHandleColor: theme.accentColor,
      ),
    );
  }

  MaterialColor _findMainColor(Color shadeColor) {
    if (shadeColor == null) return null;

    for (final mainColor in app_material_colors)
      if (_isShadeOfMain(mainColor, shadeColor)) return mainColor;

    Map<int, Color> shades = {50: shadeColor};
    for (var i = 100; i <= 900; i += 100)
      shades.putIfAbsent(i, () => shadeColor);

    return MaterialColor(shadeColor.value, shades);
  }

  bool _isShadeOfMain(MaterialColor mainColor, Color shadeColor) {
    List<Color> shades = [mainColor.shade50];
    for (var i = 100; i <= 900; i += 100) shades.add(mainColor[i]);

    for (var shade in shades) if (shade == shadeColor) return true;
    return false;
  }
}
