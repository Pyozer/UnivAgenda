import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:univagenda/models/courses/base_course.dart';
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/utils/date.dart';
import 'package:univagenda/utils/preferences.dart';
import 'package:univagenda/widgets/course/course_row.dart';
import 'package:univagenda/widgets/course/course_row_header.dart';
import 'package:univagenda/widgets/ui/screen_message/empty_day.dart';

import '../../keys/pref_key.dart';
import '../../screens/detail_course/detail_course.dart';
import '../../utils/functions.dart';

class CourseList extends StatefulWidget {
  final Map<int, List<Course>> coursesData;
  final CalendarController calendarController;

  const CourseList({
    Key? key,
    required this.coursesData,
    required this.calendarController,
  }) : super(key: key);

  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  DateTime? _currentSelectedDate;

  Widget _buildListCours(BuildContext context, List<BaseCourse?>? courses) {
    List<Widget> widgets = [];

    final noteColor = context.read<PrefsProvider>().theme.noteColor;

    bool classicView =
        widget.calendarController.view == CalendarView.timelineDay;

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
    PrefsProvider prefs,
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

    final baseStyle = theme.primaryTextTheme.headline6;
    final unselectedStyle = baseStyle!.copyWith(
      fontSize: 17.0,
      color: baseStyle.color!.withAlpha(180),
    );
    final labelStyle = unselectedStyle.copyWith(color: baseStyle.color);

    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              isScrollable: true,
              tabs: tabs,
              labelColor: labelStyle.color,
              labelStyle: labelStyle,
              unselectedLabelColor: theme.primaryTextTheme.caption!.color,
              unselectedLabelStyle: unselectedStyle,
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

  // Widget _buildDialog(
  //   BuildContext context,
  //   DateTime date,
  //   Map<DateTime, List<Course>> events,
  // ) {
  //   List<Course> courseEvents = _getDayEvents(date, events);

  //   return Dialog(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  //     child: Container(
  //       constraints: const BoxConstraints(maxHeight: 480),
  //       child: _buildListCours(context, courseEvents),
  //     ),
  //   );
  // }

  // List<Course> _getDayEvents(DateTime day, Map<DateTime, List<Course>> data) {
  //   DateTime? key =
  //       data.keys.firstWhereOrNull((d) => DateUtils.isSameDay(day, d));
  //   if (key == null) return [];

  //   return data[key]!.whereNotNull().toList();
  // }

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
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Builder(
        builder: (_) => SfCalendar(
          controller: widget.calendarController,
          dataSource: MeetingDataSource(
            events.values.flattened.toList(),
            isGenColor,
            Theme.of(context).cardColor,
          ),
          monthViewSettings: MonthViewSettings(
            showAgenda: _currentSelectedDate != null,
            appointmentDisplayCount: 4,
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            agendaViewHeight: 200,
            dayFormat: 'EEE',
          ),
          appointmentTimeTextFormat: 'Hm',
          showDatePickerButton: true,
          showNavigationArrow: true,
          minDate: DateTime.now()
              .subtract(Duration(days: PrefKey.defaultMaximumPrevDays)),
          initialSelectedDate: DateTime.now(),
          firstDayOfWeek: 1,
          onTap: (details) {
            if (details.targetElement == CalendarElement.calendarCell &&
                widget.calendarController.view == CalendarView.month) {
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
            } // else {
            //   showDialog(
            //     context: context,
            //     builder: (dCtx) => _buildDialog(dCtx, details.date!, events),
            //   );
            // }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PrefsProvider>();

    if (widget.calendarController.view == CalendarView.timelineDay) {
      return _buildHorizontal(context, prefs, widget.coursesData);
    }
    return _buildCalendar(
      context,
      prefs.isGenerateEventColor,
      widget.coursesData,
    );
  }
}

class MeetingDataSource extends CalendarDataSource<Course> {
  bool _isGenColor = false;
  late Color _defaultBgColor;

  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(
      List<Course> source, bool isGenColor, Color defaultBgColor) {
    appointments = source;
    _isGenColor = isGenColor;
    _defaultBgColor = defaultBgColor;
  }

  Course getEvent(int index) {
    return appointments![index];
  }

  @override
  DateTime getStartTime(int index) {
    return getEvent(index).dateStart;
  }

  @override
  DateTime getEndTime(int index) {
    if (isAllDay(index)) {
      return getEvent(index).dateEnd.subtract(Duration(milliseconds: 1));
    }
    return getEvent(index).dateEnd;
  }

  @override
  String getSubject(int index) {
    return getEvent(index).title;
  }

  @override
  String? getNotes(int index) =>
      getEvent(index).notes.map((e) => e.text).join((', '));

  @override
  Color getColor(int index) {
    return getEvent(index).getBgColor(_isGenColor) ?? _defaultBgColor;
  }

  @override
  bool isAllDay(int index) {
    final event = getEvent(index);
    if (event.dateStart.hour == 0 &&
        event.dateStart.minute == 0 &&
        event.dateStart.second == 0) {
      if (event.dateEnd.difference(event.dateStart).inSeconds %
              (24 * 60 * 60) ==
          0) {
        return true;
      }
    }
    return false;
  }
}
