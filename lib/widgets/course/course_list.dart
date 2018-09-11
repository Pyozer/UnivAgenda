import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course/course_list_header.dart';
import 'package:myagenda/widgets/course/course_row.dart';
import 'package:myagenda/widgets/course/course_row_header.dart';
import 'package:myagenda/widgets/ui/about_card.dart';

class CourseList extends StatelessWidget {
  final Map<DateTime, List<BaseCourse>> courses;
  final String coursesHeader;
  final int numberWeeks;
  final bool isHorizontal;
  final Color noteColor;

  const CourseList({
    Key key,
    @required this.courses,
    @required this.coursesHeader,
    @required this.numberWeeks,
    @required this.noteColor,
    this.isHorizontal = false,
  }) : super(key: key);

  Widget _buildListCours(BuildContext context, List<BaseCourse> courses) {
    List<Widget> widgets = [];

    if (courses != null) {
      courses.forEach((course) {
        if (course is CourseHeader)
          widgets.add(CourseRowHeader(coursHeader: course));
        else if (course is Course)
          widgets.add(CourseRow(course: course, noteColor: noteColor));
      });
    }

    return ListView(
      shrinkWrap: true,
      children: widgets,
      padding: EdgeInsets.only(bottom: 12.0, top: isHorizontal ? 12.0 : 0.0),
    );
  }

  Widget _buildHorizontal(context, Map<DateTime, List<BaseCourse>> elements) {
    if (elements.length < 1) {
      return const SizedBox.shrink();
    }

    final langCode = Translations.of(context).locale.languageCode;
    final textTheme = Theme.of(context).textTheme;
    List<Widget> listTabView = [];
    List<Widget> tabs = [];
    // Build horizontal view
    elements.forEach((date, courses) {
      tabs.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Text(
            DateFormat.MEd(langCode).format(date),
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
        TabBar(
          isScrollable: true,
          tabs: tabs,
        ),
        Expanded(
          child: TabBarView(
            children: listTabView,
          ),
        ),
      ]),
    );
  }

  Widget _buildVertical(context, Map<DateTime, List<BaseCourse>> elements) {
    // Build vertical view
    final List<BaseCourse> listChildren = [];
    elements.forEach((date, courses) {
      listChildren.add(CourseHeader(date));
      listChildren.addAll(courses);
    });

    return _buildListCours(context, listChildren);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          CourseListHeader(coursesHeader),
          Divider(height: 0.0),
          Expanded(
            child: Container(
              child: (isHorizontal)
                  ? _buildHorizontal(context, courses)
                  : _buildVertical(context, courses),
            ),
          ),
        ],
      ),
    );
  }
}
