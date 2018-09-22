import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  static final boldText = const TextStyle(fontWeight: FontWeight.w600);

  final String title;
  final String text;

  const ProgressDialog({Key key, this.title, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: boldText),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 16.0),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
