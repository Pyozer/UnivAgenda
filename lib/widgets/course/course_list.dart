import 'package:flutter/material.dart';
import 'package:flutter_calendar/date_utils.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:univagenda/models/calendar_type.dart';
import 'package:univagenda/models/courses/base_course.dart';
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/screens/base_state.dart';
import 'package:univagenda/utils/date.dart';
import 'package:univagenda/utils/preferences.dart';
import 'package:univagenda/widgets/calendar/calendar_event.dart';
import 'package:univagenda/widgets/course/course_row.dart';
import 'package:univagenda/widgets/course/course_row_header.dart';
import 'package:univagenda/widgets/ui/screen_message/empty_day.dart';

class CourseList extends StatefulWidget {
  final Map<int, List<Course>> coursesData;
  final CalendarType calType;

  const CourseList({
    Key key,
    @required this.coursesData,
    this.calType = CalendarType.VERTICAL,
  }) : super(key: key);

  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends BaseState<CourseList> {
  Widget _buildListCours(BuildContext context, List<BaseCourse> courses) {
    List<Widget> widgets = [];

    final noteColor = prefs.theme.noteColor;

    bool classicView = (widget.calType == CalendarType.HORIZONTAL ||
        widget.calType == CalendarType.VERTICAL);

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
        top: widget.calType == CalendarType.VERTICAL ? 0.0 : 12.0,
      ),
    );
  }

  Widget _buildHorizontal(context, Map<int, List<Course>> elements) {
    if (elements.isEmpty) return const SizedBox.shrink();

    List<Widget> listTabView = [];
    List<Widget> tabs = [];

    // Build horizontal view
    final today = Date.dateToInt(DateTime.now());
    int initialIndex = 0;
    bool isIndexFound = false;

    elements.forEach((date, courses) {
      if (!prefs.isDisplayAllDays && (courses == null || courses.isEmpty)) return;
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

    final baseStyle = theme.primaryTextTheme.title;
    final unselectedStyle = baseStyle.copyWith(
      fontSize: 17.0,
      color: baseStyle.color.withAlpha(180),
    );
    final labelStyle = unselectedStyle.copyWith(color: baseStyle.color);

    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: theme.primaryColor,
            child: TabBar(
              isScrollable: true,
              tabs: tabs,
              labelColor: labelStyle.color,
              labelStyle: labelStyle,
              unselectedLabelColor: theme.primaryTextTheme.caption.color,
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

  Widget _buildVertical(context, Map<int, List<Course>> elements) {
    // Build vertical view
    final List<BaseCourse> listChildren = [];
    elements.forEach((date, courses) {
      if (courses == null || courses.isEmpty) return;

      List<Course> filteredCourses =
          courses.where((c) => c.dateEnd.isAfter(DateTime.now())).toList();

      if (filteredCourses.isEmpty) return;

      listChildren.add(CourseHeader(Date.intToDate(date)));
      listChildren.addAll(filteredCourses);
    });

    return _buildListCours(context, listChildren);
  }

  Widget _buildDialog(BuildContext context, DateTime date, Map events) {
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
    DateTime key = data.keys.firstWhere(
      (d) => DateUtils.isSameDay(day, d),
      orElse: () => null,
    );
    if (key != null)
      return data[key]
          .map((e) => e is Course ? e : null)
          .where((c) => c != null)
          .toList();
    return [];
  }

  Widget _buildCalendar(context, Map<int, List<Course>> elements) {
    var events = elements.map(
      (intDate, events) => MapEntry(Date.intToDate(intDate), events),
    );

    final isGenColor = PreferencesProvider.of(context).isGenerateEventColor;

    // Build calendar view
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Calendar(
        monthView: widget.calType == CalendarType.MONTH_VIEW,
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        initialSelectedDate: DateTime.now(),
        dayBuilder: (_, date) => _getDayEvents(date, events).map((e) {
          return Event(
            title: e.isHidden ? null : e.getTitle(),
            color: e.getColor(isGenColor),
          );
        }).toList(),
        onDateSelected: (date) {
          showDialog(
            context: context,
            builder: (dCtx) => _buildDialog(dCtx, date, events),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (widget.calType == CalendarType.VERTICAL)
      content = _buildVertical(context, widget.coursesData);
    else if (widget.calType == CalendarType.HORIZONTAL)
      content = _buildHorizontal(context, widget.coursesData);
    else
      content = _buildCalendar(context, widget.coursesData);

    return content;
  }
}
