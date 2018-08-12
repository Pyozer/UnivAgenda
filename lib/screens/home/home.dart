import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/cours_list.dart';
import 'package:myagenda/widgets/drawer.dart';

class HomeScreen extends StatelessWidget {
  FloatingActionButton _buildFab() =>
      FloatingActionButton(onPressed: () {
        // TODO: Faire fullscreen dialog pour ajouter un cours perso
      }, child: Icon(Icons.add));

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
        title: Translations.of(context).get(StringKey.APP_NAME),
        drawer: MainDrawer(),
        fab: _buildFab(),
        body: CoursList());
  }
}
