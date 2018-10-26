import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';

class CourseListHeader extends StatelessWidget {
  final String text;
  final Color bgColor;

  const CourseListHeader(this.text, {Key key, this.bgColor}) : super(key: key);

  Future<Null> _onHeaderTap(BuildContext mainContext) async {
    final translations = Translations.of(mainContext);

    bool btnPositivePressed = await DialogPredefined.showTextDialog(
      mainContext,
      translations.get(StringKey.CHANGE_AGENDA),
      translations.get(StringKey.CHANGE_AGENDA_TEXT),
      translations.get(StringKey.CHANGE),
      translations.get(StringKey.CANCEL),
    );

    if (btnPositivePressed) {
      Navigator.of(mainContext).pushNamed(RouteKey.SETTINGS);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (text == null) return const SizedBox.shrink();

    const textStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0);

    return InkWell(
      onTap: () => _onHeaderTap(context),
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.all(12.0),
        alignment: Alignment.center,
        child: Text(text, style: textStyle, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
