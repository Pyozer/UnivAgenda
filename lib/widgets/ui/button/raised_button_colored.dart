import 'package:flutter/material.dart';
import 'package:univagenda/utils/functions.dart';

class RaisedButtonColored extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final Widget? child;
  final RoundedRectangleBorder? shape;
  final EdgeInsets? padding;

  const RaisedButtonColored({
    Key? key,
    this.text,
    this.child,
    required this.onPressed,
    this.shape,
    this.padding,
  })  : assert(text != null || child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).accentColor;
    final color = getColorDependOfBackground(accentColor);

    return ElevatedButton(
      child: text != null
          ? Text(
              text!.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          : child,
      onPressed: onPressed,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          shape ??
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        backgroundColor: MaterialStateProperty.all(accentColor),
        textStyle: MaterialStateProperty.all(TextStyle(color: color)),
        padding: MaterialStateProperty.all(
          padding ??
              const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
        ),
      ),
    );
  }
}
