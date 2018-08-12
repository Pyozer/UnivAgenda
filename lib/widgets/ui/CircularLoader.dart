import 'package:flutter/material.dart';

class CircularLoader extends StatelessWidget {
  final Color color;

  const CircularLoader({Key key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
        strokeWidth: 4.0,
        valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).primaryColor));
  }
}
