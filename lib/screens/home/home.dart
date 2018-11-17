import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/analytics.dart';
import 'package:myagenda/models/courses/base_course.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/courses/custom_course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/screens/custom_event/custom_event.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/ical_api.dart';
import 'package:myagenda/widgets/course/course_list.dart';
import 'package:myagenda/widgets/course/course_list_header.dart';
import 'package:myagenda/widgets/drawer.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/no_result.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen> {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<int, List<BaseCourse>> _courses;
  bool _isHorizontal = false;

  List<String> _lastGroupKeys;
  String _lastUrlIcs;
  int _lastNumberWeeks = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Define type of view
    _isHorizontal = prefs.isHorizontalView;

    bool isPrefsDifferents = false;
    if (prefs.urlIcs != _lastUrlIcs ||
        prefs.groupKeys != _lastGroupKeys ||
        prefs.numberWeeks > _lastNumberWeeks) {
      // Update local values
      _lastUrlIcs = prefs.urlIcs;
      _lastGroupKeys = prefs.groupKeys;
      _lastNumberWeeks = prefs.numberWeeks;
      isPrefsDifferents = true;
    }

    // Load cached ical
    if (Ical.isValidIcal(prefs.cachedIcal))
      _prepareList(prefs.cachedIcal);
    else
      _courses = null;

    // Update courses if prefs changes or cached ical older than 15min
    if (isPrefsDifferents ||
        prefs.cachedIcalDate.difference(DateTime.now()).inMinutes > 15) {
      // Load ical from network
      _fetchData();
      // Send analytics to have stats of prefs users
      _sendAnalyticsEvent();
    }
  }

  void _sendAnalyticsEvent() async {
    // User group, display and colors prefs
    analyticsProvider.sendUserPrefsGroup(prefs);
    analyticsProvider.sendUserPrefsDisplay(prefs);
    analyticsProvider.sendUserPrefsColor(prefs);
  }

  Future<Null> _fetchData() async {
    _refreshKey?.currentState?.show();

    if (mounted) {
      String url;
      if (prefs.urlIcs == null) {
        final resID = prefs.getGroupResID();

        url = IcalAPI.prepareURL(
          prefs.university.agendaUrl,
          resID,
          prefs.numberWeeks,
        );
      } else {
        url = prefs.urlIcs;
      }
      final response = await HttpRequest.get(url);

      if (!response.isSuccess) {
        _scaffoldKey?.currentState?.removeCurrentSnackBar();
        _scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(translation(StrKey.NETWORK_ERROR)),
        ));
        return null;
      }
      final String icalStr = utf8.decode(response.httpResponse.bodyBytes);
      await _prepareList(icalStr);
      prefs.setCachedIcal(icalStr);
    }

    return null;
  }

  Course _addNotesToCourse(List<Note> notes, Course course) {
    // Get all note of the course
    final courseNotes =
        notes.where((note) => note.courseUid == course.uid).toList();
    // Sorts notes by date desc
    courseNotes.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
    // Add notes to the course
    course.notes = courseNotes;

    return course;
  }

  List<CustomCourse> _generateRepeatedCourses(CustomCourse course) {
    List<CustomCourse> courses = [];

    final int numberDay = DateTime.daysPerWeek * prefs.numberWeeks;
    final Duration addOneDay = Duration(days: 1);

    DateTime dayDate = DateTime.now();
    for (int day = 0; day < numberDay; day++) {
      // Check if actual day is in weekdays's course list
      if (course.weekdaysRepeat.contains(dayDate.weekday)) {
        CustomCourse courseRepeated = CustomCourse.fromJson(course.toJson());
        courseRepeated.dateStart = Date.setTimeFromOther(
          dayDate,
          course.dateStart,
        );
        courseRepeated.dateEnd = Date.setTimeFromOther(dayDate, course.dateEnd);
        // Add course to list
        courses.add(courseRepeated);
      }
      dayDate = dayDate.add(addOneDay);
    }

    return courses;
  }

  Future<void> _prepareList(String icalStr) async {
    List<Course> listCourses = [];
    // Get all notes saved (expired notes removed by getNotes())
    List<Note> allNotes = prefs.notes;
    // Get all custom events (except expired)
    List<CustomCourse> customEvents = prefs.customEvents;

    // Add custom courses with their notes to list
    for (final course in customEvents) {
      if (course.isRecurrentEvent()) {
        List<CustomCourse> customCourses = _generateRepeatedCourses(course);
        customCourses.forEach((customCourse) {
          listCourses.add(_addNotesToCourse(allNotes, customCourse));
        });
      } else {
        listCourses.add(_addNotesToCourse(allNotes, course));
      }
    }

    // Parse string ical to object
    List<Course> courseFromIcal = await Ical.parseToIcal(icalStr);

    if (courseFromIcal == null) {
      DialogPredefined.showICSFormatError(context);
      return;
    }

    final actualDate = DateTime.now();
    final maxDate = actualDate.add(
      Duration(days: Date.calcDaysToEndDate(actualDate, prefs.numberWeeks)),
    );

    for (Course course in courseFromIcal) {
      // Check if course is not finish
      if (!course.isFinish() && course.dateStart.isBefore(maxDate)) {
        // Get all notes of the course
        course = _addNotesToCourse(allNotes, course);
        // Add course to list
        listCourses.add(course);
      }
    }

    // Sort list by date start (to add headers)
    listCourses.sort((a, b) => a.dateStart.compareTo(b.dateStart));

    // List for all Cours and header
    Map<int, List<BaseCourse>> listElement = {};

    // Add all weekdays for X week(s) depends on numberWeek pref
    if (prefs.isDisplayAllDays) {
      DateTime dayDate = Date.dateFromDateTime(DateTime.now());

      final int numberDays = Date.calcDaysToEndDate(dayDate, prefs.numberWeeks);
      for (int day = 0; day < numberDays; day++) {
        int dateValue = Date.dateToInt(dayDate);
        listElement[dateValue] = [];
        dayDate = dayDate.add(const Duration(days: 1));
      }
    }

    for (Course course in listCourses) {
      int dateValue = Date.dateToInt(course.dateStart);
      if (listElement[dateValue] == null) listElement[dateValue] = [];

      listElement[dateValue].add(course);
    }

    if (!mounted) return;
    
    setState(() {
      _courses = listElement;
    });
  }

  void _switchTypeView() {
    setState(() {
      _isHorizontal = !prefs.isHorizontalView;
    });
    prefs.setHorizontalView(!prefs.isHorizontalView);
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
        if (customCourse != null) prefs.addCustomEvent(customCourse, true);
      },
      child: const Icon(OMIcons.add),
    );
  }

  Widget _buildNoResult() {
    return NoResult(
      title: translation(StrKey.COURSES_NORESULT),
      text: translation(StrKey.COURSES_NORESULT_TEXT),
      footer: RaisedButtonColored(
        text: translation(StrKey.REFRESH),
        onPressed: _fetchData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final refreshBtn = (_isHorizontal)
        ? IconButton(
            icon: const Icon(OMIcons.refresh),
            onPressed: _fetchData,
          )
        : const SizedBox.shrink();

    final iconView = _isHorizontal ? OMIcons.viewDay : OMIcons.viewCarousel;

    var content;
    if (_courses == null) // data not loaded
      content = const Center(child: CircularProgressIndicator());
    else if (_courses.length == 0) // No course found
      content = _buildNoResult();
    else
      content = CourseList(
        coursesData: _courses,
        isHorizontal: prefs.isHorizontalView,
        numberWeeks: prefs.numberWeeks,
        noteColor: Color(prefs.theme.noteColor),
      );

    return AppbarPage(
      scaffoldKey: _scaffoldKey,
      title: translation(StrKey.APP_NAME),
      actions: <Widget>[
        refreshBtn,
        IconButton(icon: Icon(iconView), onPressed: _switchTypeView)
      ],
      drawer: MainDrawer(),
      fab: _buildFab(context),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () async {
          analyticsProvider.sendForceRefresh(AnalyticsValue.refreshCourses);
          return await _fetchData();
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            (prefs.isHeaderGroupVisible && prefs.urlIcs == null)
                ? CourseListHeader(
                    "${prefs.groupKeys[1]} - ${prefs.groupKeys.last}",
                  )
                : const SizedBox.shrink(),
            const Divider(height: 0.0),
            Expanded(
              child: Container(child: content),
            ),
          ],
        ),
      ),
    );
  }
}
