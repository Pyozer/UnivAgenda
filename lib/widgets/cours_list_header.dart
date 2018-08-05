import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/utils/preferences.dart';

class CoursListHeader extends StatelessWidget {
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
                Navigator.of(mainContext).pushNamed('/settings');
              },
            )
          ],
        );
      },
    );
  }

  Widget _futureBuilder(BuildContext context, AsyncSnapshot<String> snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      final textStyle = Theme.of(context).textTheme.title;
      return InkWell(
          onTap: () => _onHeaderTap(context),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(snapshot.data, style: textStyle))
          ]));
    } else
      return Container();
  }

  Future<String> _getGroupCalendar() async {
    String year = await Preferences.getYear();
    String group = await Preferences.getGroup();

    return "$year - $group";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _getGroupCalendar(), builder: _futureBuilder);
  }
}
