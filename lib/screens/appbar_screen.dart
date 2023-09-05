import 'package:flutter/material.dart';

import '../widgets/ui/drawer_icon.dart';

class AppbarPage extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? drawer;
  final Widget? fab;
  final List<Widget>? actions;
  final bool useCustomMenuIcon;

  const AppbarPage({
    Key? key,
    this.title,
    required this.body,
    this.drawer,
    this.fab,
    this.actions,
    this.useCustomMenuIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (title != null)
          ? AppBar(
              title: Text(title!),
              centerTitle: true,
              actions: actions ?? [],
              elevation: 0.0,
              leading: useCustomMenuIcon
                  ? Builder(
                      builder: (context) => DrawerIcon(
                        onPressed: Scaffold.of(context).openDrawer,
                      ),
                    )
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
  final String text;

  const AppbarSubTitle({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final bgColor = appBarTheme.backgroundColor ?? theme.colorScheme.surface;

    return Row(
      children: [
        Expanded(
          child: Material(
            color: bgColor,
            elevation: 0.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 17.0,
                  color: appBarTheme.foregroundColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
