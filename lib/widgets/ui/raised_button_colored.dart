import 'package:flutter/material.dart';
import 'package:myagenda/utils/functions.dart';

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
    final color = getColorDependOfBackground(accentColor);

    return RaisedButton(
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
      onPressed: onPressed,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      color: accentColor,
      textColor: color,
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
    );
  }
}
