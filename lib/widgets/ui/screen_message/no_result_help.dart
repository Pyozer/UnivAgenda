import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/widgets/ui/screen_message/no_result.dart';

class NoResultHelp extends StatelessWidget {
  const NoResultHelp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NoResult(
      title: FlutterI18n.translate(context, StrKey.HELP_NORESULT),
      text: FlutterI18n.translate(context, StrKey.HELP_NORESULT_TEXT),
    );
  }
}
