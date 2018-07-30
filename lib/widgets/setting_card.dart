import 'package:flutter/material.dart';

class SettingCard extends StatelessWidget {
  final String header;
  final List<Widget> children;

  const SettingCard({Key key, @required this.header, @required this.children});

  List<Widget> _buildCardChildren() {
    List<Widget> cardChildren = [Text(header)];
    cardChildren.addAll(children);
    return cardChildren;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildCardChildren(),
      ),
    );
  }
}
