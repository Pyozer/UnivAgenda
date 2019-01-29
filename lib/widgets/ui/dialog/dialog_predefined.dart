import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:myagenda/keys/string_key.dart';
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
      FlutterI18n.translate(ctx, StrKey.OK),
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

  static Future<bool> showProgressDialog(context, String msg) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(
          title: FlutterI18n.translate(context, StrKey.LOADING),
          text: msg,
        );
      },
    );
  }
}
