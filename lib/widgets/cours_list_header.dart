import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/utils/preferences.dart';

class CoursListHeader extends StatelessWidget {
  Future<String> _getGroupCalendar() async {
    String year = await Preferences.getYear();
    String group = await Preferences.getGroup();

    return "$year - $group";
  }

  Widget _futureBuilder(BuildContext context, AsyncSnapshot<String> snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      final textStyle = Theme.of(context).textTheme.title;
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(snapshot.data, style: textStyle))
      ]);
    } else
      return Container();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _getGroupCalendar(), builder: _futureBuilder);
  }
}
