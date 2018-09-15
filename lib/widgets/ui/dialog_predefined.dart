import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';

class DialogPredefined {
  static show(BuildContext context, String title, String text,
      String btnPositive, String btnNegative,
      [dismissable = true]) async {
    final boldText = const TextStyle(fontWeight: FontWeight.w600);

    return await showDialog<bool>(
          context: context,
          barrierDismissible: dismissable,
          builder: (BuildContext context) {
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
          },
        ) ??
        false;
  }

  static showEndTimeError(BuildContext context) {
    final translate = Translations.of(context);

    show(
      context,
      translate.get(StringKey.ERROR_END_TIME),
      translate.get(StringKey.ERROR_END_TIME_TEXT),
      translate.get(StringKey.OK),
      null,
    );
  }

  static Future<bool> showDeleteEventConfirm(BuildContext context) async {
    final translate = Translations.of(context);

    return await show(
      context,
      translate.get(StringKey.CONFIRM_EVENT_DELETE),
      translate.get(StringKey.CONFIRM_EVENT_DELETE_TEXT),
      translate.get(StringKey.YES),
      translate.get(StringKey.NO),
    );
  }
}
