import 'package:flutter/material.dart';

class RaisedButtonColored extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final ShapeBorder shape;
  final EdgeInsets padding;

  const RaisedButtonColored({
    Key key,
    @required this.text,
    this.onPressed,
    this.shape,
    this.padding,
  })  : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).accentColor;
    final brightness = ThemeData.estimateBrightnessForColor(accentColor);
    final color = (brightness == Brightness.dark) ? Colors.white : Colors.black;

    return RaisedButton(
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
      onPressed: onPressed,
      child: Text(text.toUpperCase()),
      color: Theme.of(context).accentColor,
      textColor: color,
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    );
  }
}
