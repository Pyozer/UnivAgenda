import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/no_result.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';

class NoResultHelp extends StatelessWidget {
  final Function onPressed;

  const NoResultHelp({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    return NoResult(
      title: translations.get(StringKey.HELP_NORESULT),
      text: translations.get(StringKey.HELP_NORESULT_TEXT),
      footer: RaisedButtonColored(
        text: translations.get(StringKey.REFRESH),
        onPressed: onPressed,
      ),
    );
  }
}
