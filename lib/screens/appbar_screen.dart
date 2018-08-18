import 'package:flutter/material.dart';
import 'package:myagenda/utils/dynamic_theme.dart';

class AppbarPage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget drawer;
  final Widget fab;
  final double elevation;

  const AppbarPage(
      {Key key, this.title, this.body, this.drawer, this.fab, this.elevation = 4.0})
      : super(key: key);

  void _onChangeTheme(context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    DynamicTheme
        .of(context)
        .changeTheme(brightness: isDark ? Brightness.light : Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(title),
            actions: [
              FlatButton(
                  child: Icon(Icons.lightbulb_outline),
                  onPressed: () => _onChangeTheme(context))
            ],
            elevation: elevation),
        body: body,
        drawer: drawer,
        floatingActionButton: fab);
  }
}

class AppbarSubTitle extends StatelessWidget {
  final String subtitle;

  const AppbarSubTitle({Key key, @required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.primaryTextTheme.title.copyWith(fontSize: 17.0);

    return Row(children: [
      Expanded(
          child: Material(
              color: theme.primaryColor,
              elevation: 4.0,
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  child: Text(subtitle, style: textStyle))))
    ]);
  }
}
