import 'package:flutter/material.dart';

class DrawerIcon extends StatelessWidget {
  final Function onPressed;

  const DrawerIcon({Key key, this.onPressed}) : super(key: key);

  _buildLine(Color color, double width) {
    return Container(
      width: width,
      height: 2.1,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryTextTheme.title.color;

    return IconButton(
      onPressed: onPressed,
      icon: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLine(color, 22.0),
          const SizedBox(height: 4.2),
          _buildLine(color, 16.0),
          const SizedBox(height: 4.2),
          _buildLine(color, 22.0),
        ],
      ),
    );
  }
}
