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
