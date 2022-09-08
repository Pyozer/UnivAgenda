import 'package:flutter/material.dart';

class SettingCard extends StatelessWidget {
  final String header;
  final List<Widget> children;

  const SettingCard({Key? key, required this.header, required this.children});

  List<Widget> _buildCardChildren(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headline6!.copyWith(
      fontSize: 15.0,
      color: theme.colorScheme.secondary,
    );

    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 16.0, bottom: 8.0),
        child: Text(header.toUpperCase(), style: titleStyle),
      ),
      ...children
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      elevation: 2.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildCardChildren(context),
      ),
    );
  }
}
