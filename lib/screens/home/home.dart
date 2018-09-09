import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/custom_event/custom_event.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course/course_list.dart';
import 'package:myagenda/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _getLastestRessources();
  }

  void _getLastestRessources() async {
    final response = await http.get(
        "https://rawcdn.githack.com/Pyozer/MyAgenda_Flutter/master/res/ressources.json");
    if (response.statusCode == 200 && mounted) {
      Map<String, dynamic> ressources = json.decode(response.body);
      PreferencesProvider.of(context).ressources = ressources;
      Data.allData = ressources;
    }
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final customCourse = await Navigator.of(context).push(
          CustomRoute(
            builder: (context) => CustomEventScreen(),
            fullscreenDialog: true,
          ),
        );
        PreferencesProvider.of(context).addCustomEvent(customCourse);
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = PreferencesProvider.of(context);
    return AppbarPage(
      title: Translations.of(context).get(StringKey.APP_NAME),
      drawer: MainDrawer(),
      fab: _buildFab(context),
      body: CourseList(
        isHorizontal: prefs.isHorizontalView,
        campus: prefs.campus,
        department: prefs.department,
        year: prefs.year,
        group: prefs.group,
        numberWeeks: prefs.numberWeeks,
        noteColor: Color(
          prefs.noteColor,
        ),
      ),
    );
  }
}
