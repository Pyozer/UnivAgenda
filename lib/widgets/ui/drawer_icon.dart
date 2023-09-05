import 'package:flutter/material.dart';

class DrawerIcon extends StatelessWidget {
  final VoidCallback? onPressed;

  const DrawerIcon({Key? key, this.onPressed}) : super(key: key);

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
    final theme = Theme.of(context);
    final color = theme.appBarTheme.foregroundColor ??
        theme.colorScheme.onPrimaryContainer;

    return IconButton(
      onPressed: onPressed,
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      icon: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLine(color, 20.0),
          const SizedBox(height: 4.0),
          _buildLine(color, 14.0),
          const SizedBox(height: 4.0),
          _buildLine(color, 20.0),
        ],
      ),
    );
  }
}
