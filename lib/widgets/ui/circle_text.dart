import 'package:flutter/material.dart';

class CircleText extends StatelessWidget {
  final String text;
  final bool isSelected;
  final ValueChanged<bool> onChange;

  CircleText({Key key, this.text, this.onChange, this.isSelected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChange(!isSelected);
      },
      child: CircleAvatar(
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.grey[200] : Colors.grey[900],
          ),
        ),
        backgroundColor: isSelected ? Colors.grey[700] : Colors.grey[300],
        radius: 19.0,
      ),
    );
  }
}
