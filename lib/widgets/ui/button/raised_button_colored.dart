import 'package:flutter/material.dart';

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
    return ElevatedButton(
      child: text != null ? Text(text!.toUpperCase()) : child,
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: shape,
        padding: padding,
      ),
    );
  }
}
