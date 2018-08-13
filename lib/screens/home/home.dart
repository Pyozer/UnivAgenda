import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/cours/cours_list.dart';
import 'package:myagenda/widgets/drawer.dart';
import 'package:myagenda/widgets/ui/CircularLoader.dart';

class HomeScreen extends StatelessWidget {
  FloatingActionButton _buildFab() => FloatingActionButton(
      onPressed: () {
        // TODO: Faire fullscreen dialog pour ajouter un cours perso
      },
      child: Icon(Icons.add));

  Future<Map<String, dynamic>> _getGroupValues() async {
    Map<String, dynamic> dataPrefs = await Preferences.getAllValues();
    return dataPrefs;
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
        title: Translations.of(context).get(StringKey.APP_NAME),
        drawer: MainDrawer(),
        fab: _buildFab(),
        body: FutureBuilder<Map>(
            future: _getGroupValues(),
            builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularLoader());

              final data = snapshot.data;
              return CoursList(
                  campus: data[PrefKey.campus],
                  department: data[PrefKey.department],
                  year: data[PrefKey.year],
                  group: data[PrefKey.group]);
            }));
  }
}
