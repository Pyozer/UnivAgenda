import 'package:flutter/material.dart';

class AppbarPage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget drawer;
  final Widget fab;
  final double elevation;
  final List<Widget> actions;
  final Key scaffoldKey;

  const AppbarPage(
      {Key key,
      this.title,
      @required this.body,
      this.scaffoldKey,
      this.drawer,
      this.fab,
      this.elevation = 4.0,
      this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: (title != null)
          ? AppBar(
              title: Text(title),
              actions: actions ?? [],
              elevation: elevation,
            )
          : null,
      body: SafeArea(child: body),
      drawer: drawer,
      floatingActionButton: fab,
    );
  }
}

class AppbarSubTitle extends StatelessWidget {
  final Widget child;

  const AppbarSubTitle({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Theme.of(context).primaryColor,
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
