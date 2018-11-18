import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/widgets/ui/dialog/progress_dialog.dart';
import 'package:myagenda/widgets/ui/dialog/simple_alert_dialog.dart';

class DialogPredefined {
  static final kContentPadding =
      const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 7.0);

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
          builder: (BuildContext context) {
            return SimpleAlertDialog(
              title: title,
              content: SingleChildScrollView(
                padding: contentPadding ?? kContentPadding,
                child: content,
              ),
              btnNegative: btnNegative,
              btnPositive: btnPositive,
              contentPadding: const EdgeInsets.all(0.0),
            );
          },
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

  static Future<bool> showSimpleMessage(
      BuildContext context, String title, String message) async {
    return await showTextDialog(
      context,
      title,
      message,
      FlutterI18n.translate(context, StrKey.OK),
      null,
    );
  }

  static Future<bool> showEndTimeError(BuildContext context) async {
    return await showTextDialog(
      context,
      FlutterI18n.translate(context, StrKey.ERROR_END_TIME),
      FlutterI18n.translate(context, StrKey.ERROR_END_TIME_TEXT),
      FlutterI18n.translate(context, StrKey.OK),
      null,
    );
  }

  static Future<bool> showDeleteEventConfirm(BuildContext context) async {
    return await showTextDialog(
      context,
      FlutterI18n.translate(context, StrKey.CONFIRM_EVENT_DELETE),
      FlutterI18n.translate(context, StrKey.CONFIRM_EVENT_DELETE_TEXT),
      FlutterI18n.translate(context, StrKey.YES),
      FlutterI18n.translate(context, StrKey.NO),
    );
  }

  static Future<bool> showICSFormatError(BuildContext context) async {
    return await showTextDialog(
      context,
      FlutterI18n.translate(context, StrKey.ERROR),
      FlutterI18n.translate(context, StrKey.WRONG_ICS_FORMAT),
      FlutterI18n.translate(context, StrKey.OK),
      null,
    );
  }

  static Future<bool> showProgressDialog(
      BuildContext context, String message) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(
          title: FlutterI18n.translate(context, StrKey.LOADING),
          text: message,
        );
      },
    );
  }
}
