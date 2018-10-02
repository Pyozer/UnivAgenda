import 'package:flutter/material.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';

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
      titlePadding: const EdgeInsets.all(20.0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      title: Text(title, style: boldText),
      content: Text(text, textAlign: TextAlign.justify),
      actions: <Widget>[
        (btnNegative != null)
            ? FlatButton(
                child: Text(btnNegative.toUpperCase(), style: boldText),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              )
            : const SizedBox.shrink(),
        Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: RaisedButtonColored(
            text: btnPositive,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
      ],
    );
  }
}
