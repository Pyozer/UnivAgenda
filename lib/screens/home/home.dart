import 'package:flutter/material.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/translate/string_key.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/widgets/cours_list.dart';
import 'package:myagenda/widgets/drawer.dart';

class HomeScreen extends StatelessWidget {
  FloatingActionButton _buildFab() {
    return FloatingActionButton(onPressed: () {}, child: Icon(Icons.add));
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      title: Translations.of(context).get(StringKey.APP_NAME),
      drawer: MainDrawer(),
      fab: _buildFab(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("INFO 1 - GRP 11A",
                      style: Theme.of(context).textTheme.title))
            ],
          ),
          CoursList()
        ],
      ),
    );
  }
}
