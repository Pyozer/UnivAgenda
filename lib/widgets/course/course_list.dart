import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:univagenda/models/courses/base_course.dart';
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/utils/date.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/preferences/theme.provider.dart';
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

    // TODO: Watch instead ?
    final noteColor = context.read<ThemeProvider>().noteColor;

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
        controller: widget.calendarController,
        dataSource: MeetingDataSource(
          events.values.flattened.toList(),
          isGenColor,
          Theme.of(context).cardColor,
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
        appointmentTimeTextFormat: 'Hm',
        showCurrentTimeIndicator: true,
        showDatePickerButton: true,
        showNavigationArrow: true,
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
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<SettingsProvider>();

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
  String? getNotes(int index) {
    final notes = getEvent(index).notes.map((e) => e.text).join((', '));
    if (notes.isNotEmpty) {
      print(notes);
    }
    return notes;
  }

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
      final diff = event.dateEnd.difference(event.dateStart).inSeconds;
      if (diff % (24 * 60 * 60) == 0) {
        return true;
      }
    }
    return false;
  }
}
