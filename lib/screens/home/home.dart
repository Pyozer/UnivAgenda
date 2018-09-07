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
  Map<String, dynamic> _prefs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getGroupValues();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getGroupValues();
  }

  void _getGroupValues() async {
    final prefs = PreferencesProvider.of(context).prefs;
    Map<String, dynamic> dataPrefs = await prefs.getGroupValues();
    dataPrefs[PrefKey.noteColor] = await prefs.getNoteColor();
    dataPrefs[PrefKey.isHorizontalView] = await prefs.isHorizontalView();

    setState(() {
      _prefs = dataPrefs;
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
          PreferencesProvider.of(context).prefs.addCustomEvent(customCourse);
        },
        child: const Icon(Icons.add),
      );

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return AppbarPage(
      title: translations.get(StringKey.APP_NAME),
      drawer: MainDrawer(),
      fab: _buildFab(context),
      body: (_prefs == null || _prefs.length == 0)
          ? Center(child: const CircularLoader())
          : CourseList(
              isHorizontal: _prefs[PrefKey.isHorizontalView],
              campus: _prefs[PrefKey.campus],
              department: _prefs[PrefKey.department],
              year: _prefs[PrefKey.year],
              group: _prefs[PrefKey.group],
              numberWeeks: _prefs[PrefKey.numberWeek],
              noteColor: (_prefs[PrefKey.noteColor] != null)
                  ? Color(_prefs[PrefKey.noteColor])
                  : null,
            ),
    );
  }
}
