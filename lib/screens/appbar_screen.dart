import 'package:flutter/material.dart';
import 'package:univagenda/widgets/ui/drawer_icon.dart';

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
              automaticallyImplyLeading: !useCustomMenuIcon,
              leading: useCustomMenuIcon
                  ? Builder(
                      builder: (context) => DrawerIcon(
                        onPressed: () {
                          print('YOYOYOYO');
                          Scaffold.of(context).openDrawer();
                        },
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
  final Widget child;
  final EdgeInsets? padding;

  const AppbarSubTitle({Key? key, required this.child, this.padding})
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
              padding: padding ?? const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
