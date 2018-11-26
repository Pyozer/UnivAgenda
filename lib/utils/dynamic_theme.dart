import 'package:flutter/material.dart';

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
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        toggleableActiveColor: theme.accentColor,
        textSelectionHandleColor: theme.accentColor,
      ),
    );
  }
}
