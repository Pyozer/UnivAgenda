import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/screens/custom_event/custom_event.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/ical_api.dart';
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
  var _refreshKey = GlobalKey<RefreshIndicatorState>();
  Map<DateTime, List<BaseCourse>> _courses = {};
  bool _isHorizontal = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prefs = PreferencesProvider.of(context);
    // Define type of view
    _isHorizontal = prefs.isHorizontalView;

    _courses = {};

    // Load cached ical
    final ical = prefs.cachedIcal;
    if (ical != null && ical.isNotEmpty) {
      _prepareList(ical);
    }

    // Load ical from network
    _fetchData();
  }

  Future<Null> _fetchData() async {
    _refreshKey?.currentState?.show();

    final startTime = DateTime.now();

    final prefs = PreferencesProvider.of(context);

    final resID = prefs.getGroupRes(
        prefs.campus, prefs.department, prefs.year, prefs.group);

    final url = IcalAPI.prepareURL(
      resID,
      prefs.numberWeeks,
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200 && mounted) {
        _prepareList(response.body);
        PreferencesProvider.of(context).setCachedIcal(response.body, false);
      }
    } catch (_) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error"),
        ),
      );
    }

    final endTime = DateTime.now();
    final diff = endTime.difference(startTime);

    final waitTime =
        (diff.inMilliseconds < 1500) ? 1500 - diff.inMilliseconds : 0;

    await Future.delayed(Duration(milliseconds: waitTime));

    return null;
  }

  Course _addNotesToCourse(List<Note> notes, Course course) {
    // Get all note of the course
    final courseNotes = PreferencesProvider.of(context).notesOfCourse(course);

    // Sorts notes by date desc
    courseNotes.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));

    // Add notes to the course
    course.notes = courseNotes;

    return course;
  }

  void _prepareList(String icalStr) {
    List<Course> listCourses = [];

    final prefs = PreferencesProvider.of(context);

    // Get all notes saved (expired notes removed by getNotes())
    List<Note> allNotes = prefs.notes;

    // Get all custom events (except expired)
    List<Course> customEvents = prefs.customEvents;

    // Add custom courses with their notes to list
    for (final course in customEvents) {
      listCourses.add(_addNotesToCourse(allNotes, course));
    }

    // Parse string ical to object
    for (final icalModel in Ical.parseToIcal(icalStr)) {
      // Transform IcalModel to Course
      Course course = Course.fromIcalModel(icalModel);
      // Check if course is not finish
      if (!course.isFinish()) {
        // Get all notes of the course
        course = _addNotesToCourse(allNotes, course);

        // Add course to list
        listCourses.add(course);
      }
    }

    // Sort list by date start (to add headers)
    listCourses.sort((a, b) => a.dateStart.compareTo(b.dateStart));

    // List for all Cours and header
    Map<DateTime, List<BaseCourse>> listElement = {};

    // Init variable to add headers
    DateTime lastDate = DateTime(1970); // Init variable to 1970

    // Add headers to course list
    List<BaseCourse> listCourseDay = [];
    for (int i = 0; i < listCourses.length; i++) {
      final Course course = listCourses[i];

      if (Date.notSameDay(course.dateStart, lastDate)) {
        if (i != 0) {
          listElement[lastDate] = listCourseDay;
          listCourseDay = [];
        }
        lastDate = course.dateStart;
      }

      listCourseDay.add(course);
    }

    if (mounted) {
      setState(() {
        _courses = listElement;
      });
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

  void _switchTypeView() {
    final prefs = PreferencesProvider.of(context);
    setState(() {
      _isHorizontal = !prefs.isHorizontalView;
    });
    prefs.setHorizontalView(!prefs.isHorizontalView, false);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = PreferencesProvider.of(context);

    return AppbarPage(
      title: Translations.of(context).get(StringKey.APP_NAME),
      actions: <Widget>[
        _isHorizontal
            ? IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchData,
              )
            : const SizedBox.shrink(),
        IconButton(
          icon: Icon(_isHorizontal ? Icons.view_day : Icons.view_week),
          onPressed: _switchTypeView,
        )
      ],
      drawer: MainDrawer(),
      fab: _buildFab(context),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _fetchData,
        child: CourseList(
          courses: _courses,
          isHorizontal: prefs.isHorizontalView,
          coursesHeader: "${prefs.year} - ${prefs.group}",
          numberWeeks: prefs.numberWeeks,
          noteColor: Color(prefs.noteColor),
        ),
      ),
    );
  }
}
