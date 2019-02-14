import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/screen_message/no_result.dart';

class NoResultHelp extends StatelessWidget {
  const NoResultHelp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NoResult(
      title: translations.text(StrKey.HELP_NORESULT),
      text: translations.text(StrKey.HELP_NORESULT_TEXT),
    );
  }
}
