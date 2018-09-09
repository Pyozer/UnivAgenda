import 'package:flutter/material.dart';

class RaisedButtonColored extends StatelessWidget {
  static const kShape = const OutlineInputBorder();

  final VoidCallback onPressed;
  final String text;
  final ShapeBorder shape;
  final EdgeInsets padding;

  const RaisedButtonColored({
    Key key,
    this.text,
    this.onPressed,
    this.shape = kShape,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).accentColor;
    final brightness = ThemeData.estimateBrightnessForColor(accentColor);
    final color = (brightness == Brightness.dark) ? Colors.white : Colors.black;

    return RaisedButton(
      shape: shape,
      onPressed: onPressed,
      child: Text(text),
      color: Theme.of(context).accentColor,
      textColor: color,
      padding: padding,
    );
  }
}
