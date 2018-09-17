import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/no_result.dart';

class NoResultHelp extends StatelessWidget {

  const NoResultHelp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    return NoResult(
      title: translations.get(StringKey.HELP_NORESULT),
      text: translations.get(StringKey.HELP_NORESULT_TEXT),
    );
  }
}
