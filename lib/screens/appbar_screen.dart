import 'package:flutter/material.dart';

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
        appBar: AppBar(title: Text(title)),
        body: body,
        drawer: drawer,
        floatingActionButton: fab);
  }
}
