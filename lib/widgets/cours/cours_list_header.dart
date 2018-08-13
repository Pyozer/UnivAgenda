import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/route_key.dart';

class CoursListHeader extends StatelessWidget {
  final String year;
  final String group;

  const CoursListHeader({Key key, this.year, this.group}) : super(key: key);

  Future<Null> _onHeaderTap(BuildContext mainContext) async {
    return showDialog<Null>(
      context: mainContext,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change calendar ?'),
          content: Text('Do you want to change your calendar settings ?'),
          actions: [
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text('CHANGE'),
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

  String _getText() {
    return "$year - $group";
  }

  @override
  Widget build(BuildContext context) {
    if (year != null && group != null) {
      final textStyle = Theme.of(context).textTheme.title;
      return InkWell(
          onTap: () => _onHeaderTap(context),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_getText(), style: textStyle))
          ]));
    } else
      return Container();
  }
}
