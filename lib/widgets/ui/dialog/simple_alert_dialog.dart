import 'package:flutter/material.dart';

class SimpleAlertDialog extends StatelessWidget {
  static final boldText = const TextStyle(fontWeight: FontWeight.w600);

  final String title;
  final String text;
  final String btnPositive;
  final String btnNegative;

  const SimpleAlertDialog(
      {Key key, this.title, this.text, this.btnPositive, this.btnNegative})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: boldText),
      content: Text(text),
      actions: <Widget>[
        (btnNegative != null)
            ? FlatButton(
                child: Text(btnNegative, style: boldText),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              )
            : const SizedBox.shrink(),
        FlatButton(
          child: Text(btnPositive, style: boldText),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
