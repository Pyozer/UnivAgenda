import 'package:flutter/material.dart';

class ListTileTitle extends StatelessWidget {
  final String title;

  const ListTileTitle(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w500));
  }
}
