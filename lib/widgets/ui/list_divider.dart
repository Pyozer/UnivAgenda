import 'package:flutter/material.dart';

class ListDivider extends StatelessWidget {
  const ListDivider({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: const Divider(height: 0.0),
    );
  }
}
