import 'package:flutter/material.dart';
import 'package:myagenda/widgets/ui/button/raised_button_colored.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';

class SimpleAlertDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String btnPositive;
  final String btnNegative;
  final EdgeInsets contentPadding;

  const SimpleAlertDialog({
    Key key,
    @required this.title,
    @required this.content,
    @required this.btnPositive,
    this.btnNegative,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boldText = Theme.of(context).textTheme.button;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      titlePadding: const EdgeInsets.all(20.0),
      contentPadding: contentPadding ?? kContentPadding,
      title: Text(title, style: boldText),
      content: content,
      actions: [
        if (btnNegative != null)
          FlatButton(
            child: Text(btnNegative.toUpperCase(), style: boldText),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 7.0),
          child: RaisedButtonColored(
            text: btnPositive.toUpperCase(),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
      ],
    );
  }
}
