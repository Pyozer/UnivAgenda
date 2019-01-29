import 'package:flutter/material.dart';
import 'package:myagenda/widgets/ui/drawer_icon.dart';

class AppbarPage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget drawer;
  final Widget fab;
  final List<Widget> actions;
  final bool useCustomMenuIcon;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AppbarPage({
    Key key,
    this.title,
    @required this.body,
    this.scaffoldKey,
    this.drawer,
    this.fab,
    this.actions,
    this.useCustomMenuIcon = false,
  }) : super(key: key);

  void _openDrawer() {
    scaffoldKey?.currentState?.openDrawer();
  }

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
              leading: (useCustomMenuIcon)
                  ? DrawerIcon(onPressed: _openDrawer)
                  : null,
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
  final EdgeInsets padding;

  const AppbarSubTitle({Key key, @required this.child, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Theme.of(context).primaryColor,
            elevation: 0.0,
            child: Padding(
              padding:
                  padding ?? const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
