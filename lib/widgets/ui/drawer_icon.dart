import 'package:flutter/material.dart';

class DrawerIcon extends StatelessWidget {
  final Function onPressed;

  const DrawerIcon({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryTextTheme.title.color;
    return IconButton(
      onPressed: onPressed,
      icon: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 22.0, height: 2.3, color: color),
          const SizedBox(height: 4.5),
          Container(width: 16.0, height: 2.3, color: color),
          const SizedBox(height: 4.5),
          Container(width: 22.0, height: 2.3, color: color)
        ],
      ),
    );
  }
}
