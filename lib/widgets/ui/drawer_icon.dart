import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univagenda/utils/preferences/theme.provider.dart';

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
    final theme = context.read<ThemeProvider>();
    Color color = Colors.white;

    if (!theme.darkTheme) {
      if (ThemeData.estimateBrightnessForColor(theme.primaryColor) ==
          Brightness.light) {
        color = Colors.black;
      }
    }

    return IconButton(
      onPressed: onPressed,
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
