import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';

class CourseListHeader extends StatelessWidget {
  final String text;

  const CourseListHeader(this.text, {Key key}) : super(key: key);

  Future<Null> _onHeaderTap(BuildContext mainContext) async {
    final translations = Translations.of(mainContext);

    return showDialog<Null>(
      context: mainContext,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translations.get(StringKey.CHANGE_AGENDA)),
          content: Text(translations.get(StringKey.CHANGE_AGENDA_TEXT)),
          actions: [
            FlatButton(
              child: Text(translations.get(StringKey.CANCEL).toUpperCase()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text(translations.get(StringKey.CHANGE).toUpperCase()),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(mainContext).pushNamed(RouteKey.SETTINGS);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (text == null) return const SizedBox.shrink();

    final textStyle = Theme.of(context).textTheme.title;

    return InkWell(
      onTap: () => _onHeaderTap(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(text, style: textStyle),
          )
        ],
      ),
    );
  }
}
