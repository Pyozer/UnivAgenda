import 'package:flutter/material.dart';
import 'package:flutter_calendar/date_utils.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:myagenda/models/calendar_type.Dart';
import 'package:myagenda/models/courses/base_course.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/widgets/course/course_row.dart';
import 'package:myagenda/widgets/course/course_row_header.dart';
import 'package:myagenda/widgets/ui/empty_day.dart';

class CourseList extends StatelessWidget {
  final Map<int, List<BaseCourse>> coursesData;
  final int numberWeeks;
  final CalendarType calendarType;
  final Color noteColor;

  const CourseList({
    Key key,
    @required this.coursesData,
    @required this.numberWeeks,
    @required this.noteColor,
    this.calendarType = CalendarType.VERTICAL,
  }) : super(key: key);

  Widget _buildListCours(BuildContext context, List<BaseCourse> courses) {
    List<Widget> widgets = [];

    if (courses != null && courses.length > 0) {
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
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 26.0),
      ));
    }

    return ListView(
      shrinkWrap: true,
      children: widgets,
      padding: EdgeInsets.only(
        bottom: 36.0,
        top: calendarType == CalendarType.HORIZONTAL ? 12.0 : 0.0,
      ),
    );
  }

  Widget _buildHorizontal(context, Map<int, List<BaseCourse>> elements) {
    if (elements.length < 1) return const SizedBox.shrink();

    final locale = Locale(Localizations.localeOf(context).languageCode ?? 'en');

    List<Widget> listTabView = [];
    List<Widget> tabs = [];

    // Build horizontal view
    DateTime lastDate;
    elements.forEach((date, courses) {
      if (lastDate == null || Date.dateToInt(lastDate) != date)
        lastDate = Date.intToDate(date);

      tabs.add(Tab(text: Date.dateFromNow(lastDate, locale, true)));

      listTabView.add(
        _buildListCours(context, courses),
      );
    });

    final theme = Theme.of(context);

    final baseStyle = theme.primaryTextTheme.title;
    final unselectedStyle = baseStyle.copyWith(
      fontSize: 17.0,
      color: baseStyle.color.withAlpha(180),
    );
    final labelStyle = unselectedStyle.copyWith(color: baseStyle.color);

    return DefaultTabController(
      length: elements.length,
      child: Column(
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

  Widget _buildVertical(context, Map<int, List<BaseCourse>> elements) {
    // Build vertical view
    final List<BaseCourse> listChildren = [];
    DateTime lastDate;
    elements.forEach((date, courses) {
      if (lastDate == null || Date.dateToInt(lastDate) != date)
        lastDate = Date.intToDate(date);

      listChildren.add(CourseHeader(lastDate));
      if (courses != null && courses.length > 0) listChildren.addAll(courses);
    });

    return _buildListCours(context, listChildren);
  }

  Widget buildDialog(BuildContext context, DateTime date, Map events) {
    List<Course> courseEvents = _getDayEvents(date, events);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: _buildListCours(context, courseEvents),
      ),
    );
  }

  List<Course> _getDayEvents(
      DateTime day, Map<DateTime, List<BaseCourse>> data) {
    DateTime key = data.keys
        .firstWhere((d) => DateUtils.isSameDay(day, d), orElse: () => null);
    if (key != null)
      return data[key].map((e) {
        if (e is Course) return e;
      }).toList();
    return [];
  }

  Widget _buildCalendar(context, Map<int, List<BaseCourse>> elements) {
    var events = elements.map(
      (intDate, events) => MapEntry(Date.intToDate(intDate), events),
    );

    final isGenColor = PreferencesProvider.of(context).isGenerateEventColor;
    final today = DateTime.now();

    // Build calendar view
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Calendar(
        monthView: calendarType == CalendarType.MONTH_VIEW,
        firstDate: DateTime(today.year, today.month, today.day),
        dayBuilder: (_, date) => _getDayEvents(date, events).map((e) {
              return Event(
                title: e.title,
                color: e.getColor(isGenColor),
              );
            }).toList(),
        onDateSelected: (date) => showDialog(
              context: context,
              builder: (dCtx) => buildDialog(dCtx, date, events),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var content;
    if (calendarType == CalendarType.VERTICAL)
      content = _buildVertical(context, coursesData);
    else if (calendarType == CalendarType.HORIZONTAL)
      content = _buildHorizontal(context, coursesData);
    else
      content = _buildCalendar(context, coursesData);

    return Container(child: content);
  }
}

class Event extends StatelessWidget {
  final String title;
  final Color color;

  const Event({Key key, this.title, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(top: 2.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Text(
        title,
        maxLines: 1,
        style: const TextStyle(fontSize: 10.0, color: Colors.white),
      ),
    );
  }
}
