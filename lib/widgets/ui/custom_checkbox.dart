import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final double width;
  final Color activeColor;
  final Color uncheckedColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomCheckbox(
      {Key key,
      this.width = 18.0,
      this.activeColor,
      this.uncheckedColor,
      this.value,
      @required this.onChanged})
      : super(key: key);

  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  @override
  Widget build(BuildContext context) {
    IconData icon;
    bool nextState;
    Color color;

    if (widget.value == true) {
      icon = Icons.check_box;
      nextState = false;
      color = widget.activeColor ?? Theme.of(context).accentColor;
    } else if (widget.value == null) {
      icon = Icons.indeterminate_check_box;
      nextState = false;
      color = widget.uncheckedColor ?? Colors.grey[600];
    } else {
      icon = Icons.check_box_outline_blank;
      nextState = true;
      color = widget.uncheckedColor ?? Colors.grey[700];
    }

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () {
        widget.onChanged(nextState);
      },
    );
  }
}
