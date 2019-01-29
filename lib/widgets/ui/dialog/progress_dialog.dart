import 'package:flutter/material.dart';

const boldText = TextStyle(fontWeight: FontWeight.w600);

class ProgressDialog extends StatelessWidget {
  final String title;
  final String text;

  const ProgressDialog({Key key, this.title, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: boldText),
      content: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24.0),
            Expanded(
              child: Container(
                child: Text(text, textAlign: TextAlign.justify),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
