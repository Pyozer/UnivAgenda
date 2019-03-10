import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/analytics.dart';
import 'package:myagenda/models/calendar_type.Dart';
import 'package:myagenda/models/courses/base_course.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/courses/custom_course.dart';
import 'package:myagenda/models/courses/note.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/screens/custom_event/custom_event.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/ical_api.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course/course_list.dart';
import 'package:myagenda/widgets/drawer.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/screen_message/no_result.dart';
import 'package:myagenda/widgets/ui/button/raised_button_colored.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class HomeScreen extends StatefulWidget {
  final bool isFromLogin;

  const HomeScreen({Key key, this.isFromLogin = false}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen> {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<int, List<BaseCourse>> _courses;
  CalendarType _calendarType = CalendarType.HORIZONTAL;

  List<String> _lastGroupKeys;
  String _lastUrlIcs;
  int _lastNumberWeeks = 0;
  int _lastDaysBefore = 0;

  @override
  void initState() {
    super.initState();

    if (widget.isFromLogin) _showDefaultGroupDialog();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Define type of view
    _calendarType = prefs.calendarType;

    bool isPrefsDifferents = false;
    if (prefs.urlIcs != _lastUrlIcs ||
        prefs.groupKeys != _lastGroupKeys ||
        prefs.numberWeeks != _lastNumberWeeks ||
        prefs.numberDaysBefore != _lastDaysBefore) {
      // Update local values
      _lastUrlIcs = prefs.urlIcs;
      _lastGroupKeys = prefs.groupKeys;
      _lastNumberWeeks = prefs.numberWeeks;
      _lastDaysBefore = prefs.numberDaysBefore;
      isPrefsDifferents = true;
    }

    // Load cached ical
    if (Ical(prefs.cachedIcal).isValidIcal())
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

  void _showDefaultGroupDialog() async {
    await Future.delayed(const Duration(seconds: 1));
    DialogPredefined.showSimpleMessage(
      context,
      i18n.text(StrKey.LOGIN_SUCCESSFUL),
      i18n.text(StrKey.LOGIN_SUCCESSFUL_TEXT),
    );
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
          prefs.numberDaysBefore,
        );
      } else {
        url = prefs.urlIcs;
      }
      final response = await HttpRequest.get(url);

      if (!response.isSuccess) {
        _scaffoldKey?.currentState?.removeCurrentSnackBar();
        _scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(i18n.text(StrKey.NETWORK_ERROR)),
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
    // Is full hide or just display as very small
    bool isFullHidden = prefs.isFullHiddenEvent;

    // Add custom courses with their notes to list
    for (final course in customEvents) {
      if (prefs.isCourseHidden(course)) course.isHidden = true;

      if (!course.isHidden || course.isHidden && !isFullHidden) {
        if (course.isRecurrentEvent()) {
          List<CustomCourse> customCourses = _generateRepeatedCourses(course);
          customCourses.forEach((customCourse) {
            listCourses.add(_addNotesToCourse(allNotes, customCourse));
          });
        } else {
          listCourses.add(_addNotesToCourse(allNotes, course));
        }
      }
    }

    // Parse string ical to object
    List<Course> courseFromIcal = await Ical(icalStr).parseToIcal();

    if (courseFromIcal == null) {
      DialogPredefined.showICSFormatError(context);
      return;
    }

    final actualDate = DateTime.now();
    final maxDate = actualDate.add(
      Duration(days: Date.calcDaysToEndDate(actualDate, prefs.numberWeeks)),
    );

    for (Course course in courseFromIcal) {
      if (prefs.isCourseHidden(course)) course.isHidden = true;

      if (!course.isHidden || course.isHidden && !isFullHidden) {
        // Check if course is not finish
        if (course.dateStart.isBefore(maxDate)) {
          // Get all notes of the course
          course = _addNotesToCourse(allNotes, course);
          // Add course to list
          listCourses.add(course);
        }
      }
    }

    // Sort list by date start (to add headers)
    listCourses.sort((a, b) => a.dateStart.compareTo(b.dateStart));

    // List for all Cours and header
    Map<int, List<BaseCourse>> listElement = {};

    // Add all weekdays for X week(s) depends on numberWeek pref
    if (prefs.isDisplayAllDays) {
      DateTime dayDate = Date.dateFromDateTime(actualDate);

      final int numberDays = Date.calcDaysToEndDate(dayDate, prefs.numberWeeks);
      for (int day = 0; day < numberDays; day++) {
        int dateValue = Date.dateToInt(dayDate);
        listElement[dateValue] = [];
        dayDate = dayDate.add(const Duration(days: 1));
      }
    }

    for (Course course in listCourses) {
      course.renamedTitle = prefs.renamedEvents[course.title];
      int dateValue = Date.dateToInt(course.dateStart);
      if (listElement[dateValue] == null) listElement[dateValue] = [];
      listElement[dateValue].add(course);
    }

    if (!mounted) return;

    setState(() => _courses = listElement);
  }

  void _switchTypeView() {
    setState(() => _calendarType = nextCalendarType(_calendarType));
    prefs.setCalendarType(_calendarType);
  }

  void _onFabPressed() async {
    final customCourse = await Navigator.of(context).push(
      CustomRoute(
        builder: (context) => CustomEventScreen(),
        fullscreenDialog: true,
      ),
    );
    if (customCourse != null) prefs.addCustomEvent(customCourse, true);
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: _onFabPressed,
      child: const Icon(OMIcons.add),
    );
  }

  Widget _buildNoResult() {
    return NoResult(
      title: i18n.text(StrKey.COURSES_NORESULT),
      text: i18n.text(StrKey.COURSES_NORESULT_TEXT),
      footer: RaisedButtonColored(
        text: i18n.text(StrKey.REFRESH),
        onPressed: _fetchData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final refreshBtn = IconButton(
      icon: const Icon(OMIcons.refresh),
      onPressed: _fetchData,
    );

    final iconView = getCalendarTypeIcon(_calendarType);

    var content;
    if (_courses == null) // data not loaded
      content = const Center(child: CircularProgressIndicator());
    else if (_courses.length == 0) // No course found
      content = _buildNoResult();
    else
      content = CourseList(
        coursesData: _courses,
        calType: prefs.calendarType,
        numberWeeks: prefs.numberWeeks,
        noteColor: Color(prefs.theme.noteColor),
      );

    return AppbarPage(
      scaffoldKey: _scaffoldKey,
      title: i18n.text(StrKey.APP_NAME),
      actions: [
        refreshBtn,
        IconButton(icon: Icon(iconView), onPressed: _switchTypeView)
      ],
      drawer: MainDrawer(),
      useCustomMenuIcon: true,
      fab: _buildFab(context),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () async {
          analyticsProvider.sendForceRefresh(AnalyticsValue.refreshCourses);
          return await _fetchData();
        },
        child: Container(child: content),
      ),
    );
  }
}
