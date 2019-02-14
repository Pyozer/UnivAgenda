import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/dialog/progress_dialog.dart';
import 'package:myagenda/widgets/ui/dialog/simple_alert_dialog.dart';

const kContentPadding = EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 7.0);

class DialogPredefined {
  static Future<bool> showContentDialog(
    BuildContext context,
    String title,
    Widget content,
    String btnPositive,
    String btnNegative, [
    dismissable = true,
    EdgeInsets contentPadding,
  ]) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: dismissable,
          builder: (_) => SimpleAlertDialog(
                title: title,
                content: SingleChildScrollView(
                  padding: contentPadding ?? kContentPadding,
                  child: content,
                ),
                btnNegative: btnNegative,
                btnPositive: btnPositive,
                contentPadding: EdgeInsets.zero,
              ),
        ) ??
        false;
  }

  static Future<bool> showTextDialog(
    BuildContext context,
    String title,
    String text,
    String btnPositive,
    String btnNegative, [
    dismissable = true,
  ]) async {
    return await showContentDialog(
      context,
      title,
      Text(text),
      btnPositive,
      btnNegative,
      dismissable,
    );
  }

  static Future<bool> showSimpleMessage(ctx, String title, String msg) async {
    return await showTextDialog(
      ctx,
      title,
      msg,
      translations.text(StrKey.OK),
      null,
    );
  }

  static Future<bool> showEndTimeError(BuildContext context) async {
    return await showTextDialog(
      context,
      translations.text(StrKey.ERROR_END_TIME),
      translations.text(StrKey.ERROR_END_TIME_TEXT),
      translations.text(StrKey.OK),
      null,
    );
  }

  static Future<bool> showDeleteEventConfirm(BuildContext context) async {
    return await showTextDialog(
      context,
      translations.text(StrKey.CONFIRM_EVENT_DELETE),
      translations.text(StrKey.CONFIRM_EVENT_DELETE_TEXT),
      translations.text(StrKey.YES),
      translations.text(StrKey.NO),
    );
  }

  static Future<bool> showICSFormatError(BuildContext context) async {
    return await showTextDialog(
      context,
      translations.text(StrKey.ERROR),
      translations.text(StrKey.WRONG_ICS_FORMAT),
      translations.text(StrKey.OK),
      null,
    );
  }

  static Future<bool> showProgressDialog(context, String msg) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(
          title: translations.text(StrKey.LOADING),
          text: msg,
        );
      },
    );
  }
}
