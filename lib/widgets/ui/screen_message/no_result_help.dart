import 'package:flutter/material.dart';

import '../../../keys/string_key.dart';
import '../../../utils/translations.dart';
import 'no_result.dart';

class NoResultHelp extends StatelessWidget {
  const NoResultHelp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NoResult(
      title: i18n.text(StrKey.HELP_NORESULT),
      text: i18n.text(StrKey.HELP_NORESULT_TEXT),
    );
  }
}
