import 'package:flutter/material.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/custom_event/custom_event.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course/course_list.dart';
import 'package:myagenda/widgets/drawer.dart';
import 'package:myagenda/widgets/ui/circular_loader.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> prefs;

  @override
  void initState() {
    super.initState();
    _getGroupValues();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getGroupValues();
  }

  void _getGroupValues() async {
    print("salut");
    Map<String, dynamic> dataPrefs = await Preferences.getGroupValues();
    dataPrefs[PrefKey.noteColor] = await Preferences.getNoteColor();
    dataPrefs[PrefKey.isHorizontalView] = await Preferences.isHorizontalView();

    setState(() {
      prefs = dataPrefs;
    });
  }

  Widget _buildFab(BuildContext context) => FloatingActionButton(
        onPressed: () async {
          final customCourse = await Navigator.of(context).push(
            CustomRoute(
              builder: (context) => CustomEventScreen(),
              fullscreenDialog: true,
            ),
          );

          Preferences.addCustomEvent(customCourse);
        },
        child: const Icon(Icons.add),
      );

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return AppbarPage(
      title: translations.get(StringKey.APP_NAME),
      drawer: MainDrawer(
        onOpenedScreenClose: () {
          _getGroupValues();
        },
      ),
      fab: _buildFab(context),
      body: (prefs == null || prefs.length == 0)
          ? Center(child: const CircularLoader())
          : CourseList(
              isHorizontal: prefs[PrefKey.isHorizontalView],
              campus: prefs[PrefKey.campus],
              department: prefs[PrefKey.department],
              year: prefs[PrefKey.year],
              group: prefs[PrefKey.group],
              numberWeeks: prefs[PrefKey.numberWeek],
              noteColor: prefs[PrefKey.noteColor] != null
                  ? Color(prefs[PrefKey.noteColor])
                  : null,
            ),
    );
  }
}
