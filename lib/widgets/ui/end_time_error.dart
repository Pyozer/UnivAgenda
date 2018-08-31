import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';

class DialogPredefined {
  static show(BuildContext context, String title, String text,
      [String actionText = 'OK']) {
    showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text(text),
          actions: <Widget>[
            FlatButton(
              child: Text(
                actionText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static showEndTimeError(BuildContext context) {
    final translate = Translations.of(context);

    show(
      context,
      translate.get(StringKey.ERROR_END_TIME),
      translate.get(StringKey.ERROR_END_TIME_TEXT),
      translate.get(StringKey.OK),
    );
  }
}
