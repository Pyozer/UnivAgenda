import 'package:flutter/material.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';

class SimpleAlertDialog extends StatelessWidget {
  static final boldText = const TextStyle(fontWeight: FontWeight.w600);

  final String title;
  final Widget content;
  final String btnPositive;
  final String btnNegative;
  final EdgeInsets contentPadding;

  const SimpleAlertDialog(
      {Key key, this.title, this.content, this.btnPositive, this.btnNegative, this.contentPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(20.0),
      contentPadding: contentPadding ?? DialogPredefined.kContentPadding,
      title: Text(title, style: boldText),
      content: content,
      actions: [
        (btnNegative != null)
            ? FlatButton(
                child: Text(btnNegative.toUpperCase(), style: boldText),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              )
            : const SizedBox.shrink(),
        Padding(
          padding: const EdgeInsets.only(right: 7.0),
          child: RaisedButtonColored(
            text: btnPositive.toUpperCase(),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
      ],
    );
  }
}
