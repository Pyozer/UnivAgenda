import 'package:flutter/material.dart';
import 'package:univagenda/widgets/ui/button/raised_button_colored.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';

class SimpleAlertDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String btnPositive;
  final String? btnNegative;
  final EdgeInsets? contentPadding;

  const SimpleAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.btnPositive,
    this.btnNegative,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(20.0),
      contentPadding: contentPadding ?? kContentPadding,
      title: Text(title),
      content: content,
      actions: [
        if (btnNegative != null)
          TextButton(
            child: Text(btnNegative!.toUpperCase()),
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
