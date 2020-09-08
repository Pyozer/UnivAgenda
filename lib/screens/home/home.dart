import 'dart:async';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:univagenda/keys/pref_key.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/models/analytics.dart';
import 'package:univagenda/models/calendar_type.dart';
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/models/courses/custom_course.dart';
import 'package:univagenda/models/courses/note.dart';
import 'package:univagenda/screens/base_state.dart';
import 'package:univagenda/screens/custom_event/custom_event.dart';
import 'package:univagenda/screens/appbar_screen.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/api/api.dart';
import 'package:univagenda/utils/custom_route.dart';
import 'package:univagenda/utils/date.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/course/course_list.dart';
import 'package:univagenda/widgets/drawer.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:univagenda/widgets/ui/screen_message/no_result.dart';
import 'package:univagenda/widgets/ui/button/raised_button_colored.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen>
    with AfterLayoutMixin<HomeScreen> {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  Map<int, List<Course>> _courses;
  CalendarType _calendarType = CalendarType.HORIZONTAL;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Define type of view
    _calendarType = prefs.calendarType;

    // Load cached ical
    if (_courses == null && prefs.cachedCourses != null) {
      try {
        _prepareList(prefs.cachedCourses);
      } catch (_) {}
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    AnalyticsProvider.setScreen(widget);
    _updateCourses();
    prefs.onPrefsChanges = _updateCourses;
  }

  void _updateCourses() {
    // Load ical from network
    _fetchData();
    // Send analytics to have stats of prefs users
    _sendAnalyticsEvent();
  }

  void _sendAnalyticsEvent() async {
    // User group, display and colors prefs
    AnalyticsProvider.sendUserPrefsGroup(prefs);
    AnalyticsProvider.sendUserPrefsDisplay(prefs);
    AnalyticsProvider.sendUserPrefsColor(prefs);
  }

  Future<void> _fetchData() async {
    if (!mounted && !_isLoading) return;

    setState(() => _isLoading = true);

    try {
      List<Course> courses = await Api().getCoursesCustomIcal(prefs.urlIcs);
      await _prepareList(courses);
      prefs.setCachedCourses(courses);
    } catch (e) {
      _scaffoldKey?.currentState?.removeCurrentSnackBar();
      _scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Course _addNotesToCourse(List<Note> allNotes, Course course) {
    // Get all note of the course
    final notes = allNotes.where((n) => n.courseUid == course.uid).toList();
    // Add notes to the course
    course.notes = notes;
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

  Future<void> _prepareList(List<Course> courseFromIcal) async {
    List<Course> listCourses = [];
    // Get all notes saved
    List<Note> allNotes = prefs.notes;
    // Get all custom events (except expired)
    List<CustomCourse> customEvents = prefs.customEvents;
    // Is full hide or just display as very small
    bool isFullHidden = prefs.isFullHiddenEvent;

    // Add custom courses with their notes to list
    for (final course in customEvents) {
      course.isHidden = prefs.isCourseHidden(course);

      if (!course.isHidden || (course.isHidden && !isFullHidden)) {
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

    if (courseFromIcal == null) {
      DialogPredefined.showICSFormatError(context);
      return;
    }

    final now = DateTime.now();
    final maxDate = now.add(
      Duration(days: Date.calcDaysToEndDate(now, prefs.numberWeeks)),
    );
    final minDate = now.subtract(
      Duration(days: PrefKey.defaultMaximumPrevDays),
    );
    final isPrevCourses = prefs.isPreviousCourses;

    for (Course course in courseFromIcal) {
      course.isHidden = prefs.isCourseHidden(course);

      if (!course.isHidden || course.isHidden && !isFullHidden) {
        // Check if course is not finish, or true if display previous courses
        if (course.dateEnd.isAfter(isPrevCourses ? minDate : now)) {
          // Check if course start time is before max date
          if (course.dateStart.isBefore(maxDate)) {
            // Add course with notes to list
            listCourses.add(_addNotesToCourse(allNotes, course));
          }
        }
      }
    }

    // Sort list by date start (to add headers)
    listCourses.sort((a, b) => a.dateStart.compareTo(b.dateStart));

    // List for all Cours and header
    Map<int, List<Course>> listElement = {};

    // Add all weekdays for X week(s) depends on numberWeek pref
    if (prefs.isDisplayAllDays) {
      DateTime dayDate = Date.dateFromDateTime(now);

      final int numberDays = Date.calcDaysToEndDate(dayDate, prefs.numberWeeks);
      for (int day = 0; day < numberDays; day++) {
        listElement[Date.dateToInt(dayDate)] = [];
        dayDate = dayDate.add(const Duration(days: 1));
      }
    }

    for (Course course in listCourses) {
      course.renamedTitle = prefs.renamedEvents[course.title];
      int dateValue = Date.dateToInt(course.dateStart);
      if (listElement[dateValue] == null) listElement[dateValue] = [];
      listElement[dateValue].add(course);
    }

    if (mounted) setState(() => _courses = listElement);
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

  Widget _buildNoResult() {
    return NoResult(
      title: i18n.text(StrKey.COURSES_NORESULT),
      text: i18n.text(StrKey.COURSES_NORESULT_TEXT),
      footer: RaisedButtonColored(
        text: i18n.text(StrKey.REFRESH),
        onPressed: _refreshKey?.currentState?.show,
      ),
    );
  }

  Widget _buildError() {
    return NoResult(
      title: i18n.text(StrKey.ERROR),
      text: i18n.text(StrKey.ERROR_JSON_PARSE),
      footer: RaisedButtonColored(
        text: i18n.text(StrKey.REFRESH),
        onPressed: _refreshKey?.currentState?.show,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_isLoading && _courses == null) // data not loaded
      content = const Center(child: CircularProgressIndicator());
    else if (_courses == null) // Courses fetch error
      content = _buildError();
    else if (_courses.isEmpty) // No course found
      content = _buildNoResult();
    else
      content = CourseList(coursesData: _courses, calType: prefs.calendarType);

    return AppbarPage(
      scaffoldKey: _scaffoldKey,
      title: i18n.text(StrKey.APP_NAME),
      actions: [
        IconButton(
          icon: const Icon(OMIcons.refresh),
          onPressed: _refreshKey?.currentState?.show,
        ),
        IconButton(
          icon: Icon(getCalendarTypeIcon(_calendarType)),
          onPressed: _switchTypeView,
        )
      ],
      drawer: MainDrawer(),
      useCustomMenuIcon: true,
      fab: FloatingActionButton(
        heroTag: "fabBtn",
        onPressed: _onFabPressed,
        child: const Icon(OMIcons.add),
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () {
          AnalyticsProvider.sendForceRefresh(AnalyticsValue.refreshCourses);
          return _fetchData();
        },
        child: content,
      ),
    );
  }
}
