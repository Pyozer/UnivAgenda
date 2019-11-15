import 'package:flutter/material.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/ui/screen_message/no_result.dart';

class NoResultHelp extends StatelessWidget {
  const NoResultHelp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NoResult(
      title: i18n.text(StrKey.HELP_NORESULT),
      text: i18n.text(StrKey.HELP_NORESULT_TEXT),
    );
  }
}
