import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/add_event/add_event.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course/course_list.dart';
import 'package:myagenda/widgets/drawer.dart';
import 'package:myagenda/widgets/ui/circular_loader.dart';

class HomeScreen extends StatelessWidget {
  Widget _buildFab(BuildContext context) => FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(CustomRoute(
            builder: (context) => AddEventScreen(), fullscreenDialog: true));
      },
      child: Icon(Icons.add));

  Future<Map<String, dynamic>> _getGroupValues() async {
    Map<String, dynamic> dataPrefs = await Preferences.getGroupValues();
    dataPrefs[PrefKey.noteColor] = await Preferences.getNoteColor();
    return dataPrefs;
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      title: Translations.of(context).get(StringKey.APP_NAME),
      drawer: MainDrawer(),
      fab: _buildFab(context),
      body: FutureBuilder<Map>(
        future: _getGroupValues(),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularLoader());
          }

          final data = snapshot.data;
          return CourseList(
            campus: data[PrefKey.campus],
            department: data[PrefKey.department],
            year: data[PrefKey.year],
            group: data[PrefKey.group],
            numberWeeks: data[PrefKey.numberWeek],
            noteColor: data[PrefKey.noteColor] != null
                ? Color(data[PrefKey.noteColor])
                : null,
          );
        },
      ),
    );
  }
}
