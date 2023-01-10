import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univagenda/utils/preferences/theme.provider.dart';

class CircleText extends StatelessWidget {
  final String text;
  final bool isSelected;
  final ValueChanged<bool>? onChange;

  CircleText({
    Key? key,
    required this.text,
    this.onChange,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = context.watch<ThemeProvider>().darkTheme;

    Color textColor, bgColor;
    if (isDark) {
      textColor = isSelected ? Colors.grey[900]! : Colors.grey[200]!;
      bgColor = isSelected ? Colors.grey[300]! : Colors.grey[700]!;
    } else {
      textColor = isSelected ? Colors.grey[200]! : Colors.grey[900]!;
      bgColor = isSelected ? Colors.grey[700]! : Colors.grey[300]!;
    }

    return GestureDetector(
      onTap: () => onChange != null ? onChange!(!isSelected) : null,
      child: CircleAvatar(
        child: Text(text, style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        radius: 19.0,
      ),
    );
  }
}
