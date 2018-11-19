import 'package:flutter/material.dart';

class AppbarPage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget drawer;
  final Widget fab;
  final List<Widget> actions;
  final Key scaffoldKey;

  const AppbarPage(
      {Key key,
      this.title,
      @required this.body,
      this.scaffoldKey,
      this.drawer,
      this.fab,
      this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: (title != null)
          ? AppBar(
              title: Text(title),
              centerTitle: true,
              actions: actions ?? [],
              elevation: 0.0,
            )
          : null,
      body: body,
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
            elevation: 0.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
