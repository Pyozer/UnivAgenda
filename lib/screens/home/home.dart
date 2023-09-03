import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:after_layout/after_layout.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:univagenda/keys/pref_key.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/models/analytics.dart';
import 'package:univagenda/models/calendar_type.dart';
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/models/courses/custom_course.dart';
import 'package:univagenda/models/courses/note.dart';
import 'package:univagenda/screens/custom_event/custom_event.dart';
import 'package:univagenda/screens/appbar_screen.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/api/api.dart';
import 'package:univagenda/utils/date.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/preferences/theme.provider.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/drawer.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:univagenda/widgets/ui/screen_message/no_result.dart';
import 'package:univagenda/widgets/ui/button/raised_button_colored.dart';

import '../../models/courses/base_course.dart';
import '../../models/courses/course_data_source.dart';
import '../../widgets/course/course_row.dart';
import '../../widgets/course/course_row_header.dart';
import '../../widgets/ui/screen_message/empty_day.dart';
import '../detail_course/detail_course.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AfterLayoutMixin<HomeScreen> {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();

  bool _isLoading = true;
  Map<int, List<Course>>? _courses;
  final calendarController = CalendarController();
  DateTime? _currentSelectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prefs = context.read<SettingsProvider>();
    calendarController.view = prefs.calendarType;
    // Load cached ical
    if (prefs.cachedCourses.isNotEmpty) {
      try {
        _prepareList(prefs.cachedCourses);
      } catch (_) {}
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    AnalyticsProvider.setScreen(widget);
    _updateCourses();
  }

  void _updateCourses() {
    // Load ical from network
    _fetchData();
    // Send analytics to have stats of prefs users
    _sendAnalyticsEvent();
  }

  void _sendAnalyticsEvent() async {
    final prefs = context.read<SettingsProvider>();
    final theme = context.read<ThemeProvider>();
    // User group, display and colors prefs
    AnalyticsProvider.sendUserPrefsGroup(prefs);
    AnalyticsProvider.sendUserPrefsDisplay(prefs);
    AnalyticsProvider.sendUserPrefsColor(theme);
  }

  Future<void> _fetchData() async {
    if (!mounted && !_isLoading) return;

    setState(() => _isLoading = true);

    // try {
    final prefs = context.read<SettingsProvider>();

    List<Course> courses = [];
    for (final urlIcs in prefs.urlIcs) {
      if (Uri.tryParse(urlIcs)?.hasAbsolutePath ?? false) {
        courses.addAll(await Api().getCoursesCustomIcal(urlIcs));
      }
    }

    await _prepareList(courses);
    prefs.setCachedCourses(courses);
    // } catch (e) {
    //   ScaffoldMessenger.of(context).removeCurrentSnackBar();
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(e.toString()),
    //   ));
    // }

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
    final prefs = context.read<SettingsProvider>();

    List<CustomCourse> courses = [];

    final int numberDay = DateTime.daysPerWeek * prefs.numberWeeks;

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
      dayDate = dayDate.add(Duration(days: 1));
    }

    return courses;
  }

  Future<void> _prepareList(List<Course>? courseFromIcal) async {
    final prefs = context.read<SettingsProvider>();

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
      listElement[dateValue] ??= [];
      listElement[dateValue]!.add(course);
    }

    if (mounted) setState(() => _courses = listElement);
  }

  void _switchTypeView() {
    setState(() {
      calendarController.view = nextCalendarType(calendarController.view!);
    });
    context.read<SettingsProvider>().setCalendarType(calendarController.view);
  }

  void _onFabPressed() async {
    final customCourse = await navigatorPush(
      context,
      CustomEventScreen(),
      fullscreenDialog: true,
    );
    if (customCourse != null) {
      context.read<SettingsProvider>().addCustomEvent(customCourse, true);
    }
  }

  Widget _buildNoResult() {
    return NoResult(
      title: i18n.text(StrKey.COURSES_NORESULT),
      text: i18n.text(StrKey.COURSES_NORESULT_TEXT),
      footer: RaisedButtonColored(
        text: i18n.text(StrKey.REFRESH),
        onPressed: () => _refreshKey.currentState?.show(),
      ),
    );
  }

  Widget _buildError() {
    return NoResult(
      title: i18n.text(StrKey.ERROR),
      text: i18n.text(StrKey.ERROR_JSON_PARSE),
      footer: RaisedButtonColored(
        text: i18n.text(StrKey.REFRESH),
        onPressed: () => _refreshKey.currentState?.show(),
      ),
    );
  }

  Widget _buildListCours(BuildContext context, List<BaseCourse?>? courses) {
    List<Widget> widgets = [];

    // TODO: Watch instead ?
    final noteColor = context.watch<ThemeProvider>().noteColor;

    bool classicView = calendarController.view == CalendarView.timelineDay;

    if (courses != null && courses.isNotEmpty) {
      courses.forEach((course) {
        if (course == null) {
          widgets.add(const EmptyDay());
        } else if (course is CourseHeader) {
          widgets.add(CourseRowHeader(coursHeader: course));
        } else if (course is Course) {
          widgets.add(CourseRow(course: course, noteColor: noteColor));
        }
      });
    } else {
      widgets.add(const EmptyDay(
        padding: EdgeInsets.fromLTRB(26.0, 10.0, 26.0, 16.0),
      ));
    }

    return ListView(
      children: widgets,
      padding: EdgeInsets.only(
        bottom: classicView ? 36.0 : 2.0,
        top: 12.0,
      ),
    );
  }

  Widget _buildHorizontal(
    BuildContext context,
    SettingsProvider prefs,
    Map<int, List<Course>?> elements,
  ) {
    if (elements.isEmpty) return const SizedBox.shrink();

    List<Widget> listTabView = [];
    List<Widget> tabs = [];

    // Build horizontal view
    final today = Date.dateToInt(DateTime.now());
    int initialIndex = 0;
    bool isIndexFound = false;

    elements.forEach((date, courses) {
      if (!prefs.isDisplayAllDays && (courses == null || courses.isEmpty)) {
        return;
      }
      tabs.add(Tab(text: Date.dateFromNow(Date.intToDate(date), true)));

      listTabView.add(_buildListCours(context, courses));

      final isMinEvent = date >= today;
      if (!isMinEvent && !isIndexFound) {
        initialIndex++;
      } else if (isMinEvent && !isIndexFound) {
        isIndexFound = true;
      }
    });

    if (initialIndex >= elements.length) initialIndex = 0;

    final theme = Theme.of(context);
    final bgColor =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;

    final labelStyle = theme.textTheme.titleLarge!.copyWith(
      fontSize: 17.0,
      color: getColorDependOfBackground(bgColor),
    );

    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: bgColor,
            child: TabBar.secondary(
              isScrollable: true,
              tabs: tabs,
              labelColor: labelStyle.color,
              labelStyle: labelStyle,
              unselectedLabelColor: labelStyle.color,
              unselectedLabelStyle: labelStyle,
              indicatorPadding: const EdgeInsets.only(bottom: 0.2),
              indicatorWeight: 2.5,
              indicatorColor: labelStyle.color,
            ),
          ),
          Expanded(child: TabBarView(children: listTabView)),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    bool isGenColor,
    Map<int, List<Course>> elements,
  ) {
    final events = elements.map(
      (intDate, events) => MapEntry(Date.intToDate(intDate), events),
    );

    // Build calendar view
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: SfCalendar(
        controller: calendarController,
        dataSource: CourseDataSource(
          events.values.flattened.toList(),
          isGenColor,
          Colors.grey[700]!,
        ),
        initialSelectedDate: DateTime.now(),
        minDate: DateTime.now().subtract(
          Duration(days: PrefKey.defaultMaximumPrevDays),
        ),
        firstDayOfWeek: 1,
        monthViewSettings: MonthViewSettings(
          showAgenda: _currentSelectedDate != null,
          appointmentDisplayCount: 4,
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          agendaViewHeight: 200,
          dayFormat: 'EEE',
        ),
        scheduleViewSettings: ScheduleViewSettings(
          monthHeaderSettings: MonthHeaderSettings(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        appointmentTimeTextFormat: 'Hm',
        showCurrentTimeIndicator: true,
        showDatePickerButton: true,
        showNavigationArrow: true,
        onTap: (details) {
          if (details.targetElement == CalendarElement.calendarCell &&
              calendarController.view == CalendarView.month) {
            if (_currentSelectedDate != details.date) {
              setState(() => _currentSelectedDate = details.date);
            } else {
              setState(() => _currentSelectedDate = null);
            }
          }
          if (details.targetElement != CalendarElement.appointment) return;

          if (details.appointments?.length == 1) {
            final appointment = details.appointments![0] as Course;
            navigatorPush(
              context,
              DetailCourse(course: appointment),
              fullscreenDialog: true,
            );
          }
        },
      ),
    );
  }

  Widget buildCourses(SettingsProvider prefs) {
    if (calendarController.view == CalendarView.timelineDay) {
      return _buildHorizontal(context, prefs, _courses!);
    }
    return _buildCalendar(
      context,
      prefs.isGenerateEventColor,
      _courses!,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Force didChangeDependancies to be triggered.
    final prefs = context.watch<SettingsProvider>();

    Widget content;
    if (_isLoading && _courses == null) {
      // data not loaded
      content = const Center(child: CircularProgressIndicator());
    } else if (_courses == null) {
      // Courses fetch error
      content = _buildError();
    } else if (_courses!.isEmpty) {
      // No course found
      content = _buildNoResult();
    } else {
      content = buildCourses(prefs);
    }

    return AppbarPage(
      title: i18n.text(StrKey.APP_NAME),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshKey.currentState?.show,
        ),
        IconButton(
          icon: Icon(getCalendarTypeIcon(calendarController.view!)),
          onPressed: _switchTypeView,
        )
      ],
      drawer: MainDrawer(),
      useCustomMenuIcon: true,
      fab: FloatingActionButton(
        heroTag: "fabBtn",
        onPressed: _onFabPressed,
        child: const Icon(Icons.add),
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
