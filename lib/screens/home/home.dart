import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/courses/base_course.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/courses/custom_course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/models/preferences/prefs_calendar.dart';
import 'package:myagenda/screens/custom_event/custom_event.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/ical_api.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course/course_list.dart';
import 'package:myagenda/widgets/course/course_list_header.dart';
import 'package:myagenda/widgets/drawer.dart';
import 'package:myagenda/widgets/ui/no_result.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<int, List<BaseCourse>> _courses = {};
  bool _isHorizontal = false;

  bool _isAnalyticsSended = false;

  PreferencesProviderState prefs;
  PrefsCalendar _lastPrefsCalendar;
  int _lastNumberWeeks;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    prefs = PreferencesProvider.of(context);

    // Define type of view
    _isHorizontal = prefs.isHorizontalView;

    // Load cached ical
    final cachedIcal = prefs.cachedIcal;
    if (cachedIcal != null && cachedIcal.isNotEmpty) {
      _prepareList(cachedIcal);
    }

    if (prefs.calendar != _lastPrefsCalendar ||
        prefs.numberWeeks != _lastNumberWeeks) {
      _lastPrefsCalendar = prefs.calendar;
      _lastNumberWeeks = prefs.numberWeeks;
      // Load ical from network
      _fetchData();
    }

    // Send analytics to have stats of group users
    if (!_isAnalyticsSended) _sendAnalyticsEvent();
  }

  Future<Null> _sendAnalyticsEvent() async {
    AnalyticsProvider.of(context).analytics.logEvent(
      name: 'user_group',
      parameters: <String, String>{
        'university': prefs.university.name,
        'campus': prefs.calendar.campus,
        'department': prefs.calendar.department,
        'year': prefs.calendar.year,
        'group': prefs.calendar.group,
      },
    );
    _isAnalyticsSended = true;
  }

  Future<Null> _fetchData() async {
    _refreshKey?.currentState?.show();

    if (mounted) {
      final calendar = prefs.calendar;

      final resID = prefs.getGroupRes(
        calendar.campus,
        calendar.department,
        calendar.year,
        calendar.group,
      );

      final url = IcalAPI.prepareURL(
        prefs.university.agendaUrl,
        resID,
        prefs.numberWeeks,
      );

      final response = await HttpRequest.get(url);

      if (!response.isSuccess) {
        _scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(Translations.of(context).get(StringKey.NETWORK_ERROR)),
        ));
        return null;
      }
      _prepareList(response.httpResponse.body);
      prefs.setCachedIcal(response.httpResponse.body, false);
    }

    return null;
  }

  Course _addNotesToCourse(List<Note> notes, Course course) {
    // Get all note of the course
    final courseNotes = prefs.notesOfCourse(course);

    // Sorts notes by date desc
    courseNotes.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));

    // Add notes to the course
    course.notes = courseNotes;

    return course;
  }

  List<CustomCourse> _generateRepeatedCourses(CustomCourse course) {
    List<CustomCourse> courses = [];

    final daysPerWeek = DateTime.daysPerWeek;
    final actualWeekDay = DateTime.now().weekday;

    for (int week = 0; week < prefs.numberWeeks; week++) {
      course.weekdaysRepeat.forEach((weekday) {
        int targetWD = weekday.value;

        if (targetWD < actualWeekDay && week > 0 || targetWD >= actualWeekDay) {
          int diffDays = (targetWD - actualWeekDay) % daysPerWeek;

          final duration = Duration(days: diffDays + (daysPerWeek * week));

          CustomCourse courseRepeated = CustomCourse.fromJson(course.toJson());
          courseRepeated.dateStart = course.dateStart.add(duration);
          courseRepeated.dateEnd = course.dateEnd.add(duration);

          courses.add(courseRepeated);
        }
      });
    }

    return courses;
  }

  void _prepareList(String icalStr) {
    List<Course> listCourses = [];

    // Get all notes saved (expired notes removed by getNotes())
    List<Note> allNotes = prefs.notes;

    // Get all custom events (except expired)
    List<CustomCourse> customEvents = prefs.customEvents;

    // Add custom courses with their notes to list
    for (final course in customEvents) {
      if (course.weekdaysRepeat.length > 0) {
        List<CustomCourse> customCourses = _generateRepeatedCourses(course);
        customCourses.forEach((customCourse) {
          listCourses.add(_addNotesToCourse(allNotes, customCourse));
        });
      } else {
        listCourses.add(_addNotesToCourse(allNotes, course));
      }
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
    Map<int, List<BaseCourse>> listElement = {};

    // Add all weekdays for X week(s) depends on numberWeek pref
    if (prefs.isDisplayAllDays) {
      DateTime dayDate = Date.dateFromDateTime(DateTime.now());

      final int numberDays = prefs.numberWeeks * DateTime.daysPerWeek;
      for (int day = 0; day < numberDays; day++) {
        listElement[dayDate.millisecondsSinceEpoch] = [];
        dayDate = dayDate.add(Duration(days: 1));
      }
    }

    // Init variable to add headers
    DateTime lastDate = DateTime(1970); // In0it variable to 1970

    // Add headers to course list
    List<BaseCourse> listCourseDay = [];
    for (int i = 0; i < listCourses.length; i++) {
      final Course course = listCourses[i];

      if (Date.notSameDay(course.dateStart, lastDate)) {
        if (i != 0) {
          listElement[lastDate.millisecondsSinceEpoch] = listCourseDay;
          listCourseDay = [];
        }
        lastDate = Date.dateFromDateTime(course.dateStart);
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
              routeName: RouteKey.ADD_EVENT),
        );
        if (customCourse != null) prefs.addCustomEvent(customCourse);
      },
      child: const Icon(Icons.add),
    );
  }

  void _switchTypeView() {
    setState(() {
      _isHorizontal = !prefs.isHorizontalView;
    });
    prefs.setHorizontalView(!prefs.isHorizontalView, false);
  }

  Widget _buildNoResult() {
    final translations = Translations.of(context);

    return NoResult(
      title: translations.get(StringKey.COURSES_NORESULT),
      text: translations.get(StringKey.COURSES_NORESULT_TEXT),
      footer: RaisedButtonColored(
        text: translations.get(StringKey.REFRESH),
        onPressed: _fetchData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    final refreshBtn = (_isHorizontal)
        ? IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          )
        : const SizedBox.shrink();

    final iconView = _isHorizontal ? Icons.view_day : Icons.view_week;

    return AppbarPage(
      scaffoldKey: _scaffoldKey,
      title: translations.get(StringKey.APP_NAME),
      actions: <Widget>[
        refreshBtn,
        IconButton(icon: Icon(iconView), onPressed: _switchTypeView)
      ],
      drawer: MainDrawer(),
      fab: _buildFab(context),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _fetchData,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            prefs.isHeaderGroupVisible
                ? CourseListHeader(
                    "${prefs.calendar.year} - ${prefs.calendar.group}",
                  )
                : const SizedBox.shrink(),
            const Divider(height: 0.0),
            Expanded(
              child: Container(
                child: (_courses?.length == 0 ?? true)
                    ? _buildNoResult()
                    : CourseList(
                        courses: _courses,
                        isHorizontal: prefs.isHorizontalView,
                        numberWeeks: prefs.numberWeeks,
                        noteColor: Color(prefs.theme.noteColor),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
