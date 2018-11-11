import 'package:flutter/material.dart';
import 'package:myagenda/models/courses/base_course.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course/course_row.dart';
import 'package:myagenda/widgets/course/course_row_header.dart';
import 'package:myagenda/widgets/ui/empty_day.dart';

class CourseList extends StatelessWidget {
  final Map<int, List<BaseCourse>> coursesData;
  final int numberWeeks;
  final bool isHorizontal;
  final Color noteColor;

  const CourseList({
    Key key,
    @required this.coursesData,
    @required this.numberWeeks,
    @required this.noteColor,
    this.isHorizontal = false,
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
      padding: EdgeInsets.only(bottom: 36.0, top: isHorizontal ? 12.0 : 0.0),
    );
  }

  Widget _buildHorizontal(context, Map<int, List<BaseCourse>> elements) {
    if (elements.length < 1) {
      return const SizedBox.shrink();
    }

    final locale = Translations.of(context).locale;
    final textTheme = Theme.of(context).textTheme;

    List<Widget> listTabView = [];
    List<Widget> tabs = [];

    // Build horizontal view
    DateTime lastDate;
    elements.forEach((date, courses) {
      if (lastDate == null || Date.dateToInt(lastDate) != date)
        lastDate = Date.intToDate(date);

      tabs.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Text(
            Date.dateFromNow(lastDate, locale, true),
            style: textTheme.title,
          ),
        ),
      );

      listTabView.add(
        _buildListCours(context, courses),
      );
    });

    return DefaultTabController(
      length: elements.length,
      child: Column(children: [
        TabBar(isScrollable: true, tabs: tabs),
        Expanded(child: TabBarView(children: listTabView)),
      ]),
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
      if (courses != null && courses.length > 0)
        listChildren.addAll(courses);
      else
        listChildren.add(null);
    });

    return _buildListCours(context, listChildren);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (isHorizontal)
          ? _buildHorizontal(context, coursesData)
          : _buildVertical(context, coursesData),
    );
  }
}
