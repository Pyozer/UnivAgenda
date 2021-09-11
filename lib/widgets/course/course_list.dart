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
  Widget _buildListCours(BuildContext context, List<BaseCourse?>? courses) {
    List<Widget> widgets = [];

    final noteColor = context.read<PrefsProvider>().theme.noteColor;

    // bool classicView = (widget.calType == CalendarType.HORIZONTAL ||
    //     widget.calType == CalendarType.VERTICAL);
    bool classicView = false;

    if (courses != null && courses.isNotEmpty) {
      courses.forEach((course) {
        if (course == null)
          widgets.add(const EmptyDay());
        else if (course is CourseHeader)
          widgets.add(CourseRowHeader(coursHeader: course));
        else if (course is Course)
          widgets.add(CourseRow(course: course, noteColor: noteColor));
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
        // top: widget.calType == CalendarType.VERTICAL ? 0.0 : 12.0,
        top: 12.0,
      ),
    );
  }

  // Widget _buildHorizontal(
  //     BuildContext context, Map<int, List<Course>?> elements) {
  //   if (elements.isEmpty) return const SizedBox.shrink();

  //   List<Widget> listTabView = [];
  //   List<Widget> tabs = [];

  //   // Build horizontal view
  //   final today = Date.dateToInt(DateTime.now());
  //   int initialIndex = 0;
  //   bool isIndexFound = false;

  //   elements.forEach((date, courses) {
  //     if (!prefs.isDisplayAllDays && (courses == null || courses.isEmpty))
  //       return;
  //     tabs.add(Tab(text: Date.dateFromNow(Date.intToDate(date), true)));

  //     listTabView.add(_buildListCours(context, courses));

  //     final isMinEvent = date >= today;
  //     if (!isMinEvent && !isIndexFound) {
  //       initialIndex++;
  //     } else if (isMinEvent && !isIndexFound) {
  //       isIndexFound = true;
  //     }
  //   });

  //   if (initialIndex >= elements.length) initialIndex = 0;

  //   final theme = Theme.of(context);

  //   final baseStyle = theme.primaryTextTheme.headline6;
  //   final unselectedStyle = baseStyle!.copyWith(
  //     fontSize: 17.0,
  //     color: baseStyle.color!.withAlpha(180),
  //   );
  //   final labelStyle = unselectedStyle.copyWith(color: baseStyle.color);

  //   return DefaultTabController(
  //     length: tabs.length,
  //     initialIndex: initialIndex,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         Container(
  //           color: theme.primaryColor,
  //           child: TabBar(
  //             isScrollable: true,
  //             tabs: tabs,
  //             labelColor: labelStyle.color,
  //             labelStyle: labelStyle,
  //             unselectedLabelColor: theme.primaryTextTheme.caption!.color,
  //             unselectedLabelStyle: unselectedStyle,
  //             indicatorPadding: const EdgeInsets.only(bottom: 0.2),
  //             indicatorWeight: 2.5,
  //             indicatorColor: labelStyle.color,
  //           ),
  //         ),
  //         Expanded(child: TabBarView(children: listTabView)),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildVertical(
  //     BuildContext context, Map<int, List<Course>?> elements) {
  //   // Build vertical view
  //   final List<BaseCourse> listChildren = [];
  //   elements.forEach((date, courses) {
  //     if (courses == null || courses.isEmpty) return;

  //     List<Course> filteredCourses =
  //         courses.where((c) => c.dateEnd.isAfter(DateTime.now())).toList();

  //     if (filteredCourses.isEmpty) return;

  //     listChildren.add(CourseHeader(Date.intToDate(date)));
  //     listChildren.addAll(filteredCourses);
  //   });

  //   return _buildListCours(context, listChildren);
  // }

  Widget _buildDialog(
    BuildContext context,
    DateTime date,
    Map<DateTime, List<Course>> events,
  ) {
    List<Course> courseEvents = _getDayEvents(date, events);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 480),
        child: _buildListCours(context, courseEvents),
      ),
    );
  }

  List<Course> _getDayEvents(DateTime day, Map<DateTime, List<Course>> data) {
    DateTime? key =
        data.keys.firstWhereOrNull((d) => DateUtils.isSameDay(day, d));
    if (key == null) return [];

    return data[key]!
        .map((e) => e is Course ? e : null)
        .whereNotNull()
        .toList();
  }

  Widget _buildCalendar(
    BuildContext context,
    bool isGenColor,
    Map<int, List<Course>> elements,
  ) {
    var events = elements.map(
      (intDate, events) => MapEntry(Date.intToDate(intDate), events),
    );

    // Build calendar view
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Builder(
        builder: (_) => SfCalendar(
          controller: widget.calendarController,
          monthViewSettings: MonthViewSettings(
            showAgenda: false,
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          ),
          minDate: DateTime.now().subtract(Duration(days: 365)),
          initialSelectedDate: DateTime.now(),
          firstDayOfWeek: 1,
          dataSource:
              MeetingDataSource(events.values.flattened.toList(), isGenColor),
          // dayBuilder: (_, date) => _getDayEvents(date, events).map((e) {
          //   return Event(
          //     title: e.isHidden ? null : e.getTitle(),
          //     color: e.getColor(isGenColor),
          //   );
          // }).toList(),
          onTap: (details) {
            showDialog(
              context: context,
              builder: (dCtx) => _buildDialog(dCtx, details.date!, events),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.calType == CalendarType.VERTICAL) {
    //   return _buildVertical(context, widget.coursesData);
    // }
    // if (widget.calType == CalendarType.HORIZONTAL) {
    //   return _buildHorizontal(context, widget.coursesData);
    // }
    return _buildCalendar(
      context,
      context.watch<PrefsProvider>().isGenerateEventColor,
      widget.coursesData,
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  bool _isGenColor = false;

  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Course> source, bool isGenColor) {
    appointments = source;
    _isGenColor = isGenColor;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).dateStart;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).dateEnd;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).title;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).getColor(_isGenColor) ?? Colors.transparent;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  Course _getMeetingData(int index) {
    return appointments![index];
  }
}
