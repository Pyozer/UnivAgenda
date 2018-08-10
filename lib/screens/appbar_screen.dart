import 'package:flutter/material.dart';
import 'package:myagenda/utils/dynamic_theme.dart';

class AppbarPage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget drawer;
  final Widget fab;

  const AppbarPage({Key key, this.title, this.body, this.drawer, this.fab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title), actions: <Widget>[
          FlatButton(onPressed: () {
            final isDark = (Theme.of(context).brightness == Brightness.dark);
            DynamicTheme.of(context).changeTheme(brightness: isDark ? Brightness.light : Brightness.dark);
          }, child: Icon(Icons.lightbulb_outline))
        ],),
        body: body,
        drawer: drawer,
        floatingActionButton: fab);
  }
}
