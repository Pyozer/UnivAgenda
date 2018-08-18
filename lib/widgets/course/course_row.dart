import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/screens/detail_course/detail_course.dart';
import 'package:myagenda/utils/custom_route.dart';

class CourseRow extends StatefulWidget {
  final Course course;

  const CourseRow({Key key, this.course}) : super(key: key);

  @override
  _CourseRowState createState() => _CourseRowState();
}

class _CourseRowState extends State<CourseRow> {
  Course course;

  @override
  void initState() {
    super.initState();
    setState(() {
      course = widget.course;
    });
  }

  void _onCourseTap(BuildContext context) {
    Navigator.of(context).push(CustomRoute<Course>(
        builder: (context) => DetailCourse(course: course),
        fullscreenDialog: true));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Color bgColorRow;
    if (course.isExam()) bgColorRow = Colors.red[600];

    final titleStyle = textTheme.title.copyWith(fontSize: 16.0);
    final subheadStyle = textTheme.subhead.copyWith(fontSize: 14.0);
    final cationStyle =
        textTheme.caption.copyWith(fontSize: 14.0, fontWeight: FontWeight.w500);

    final noteBorder = course.hasNote()
        ? Border(right: BorderSide(color: Colors.yellow, width: 5.0))
        : null;

    return InkWell(
        onTap: () => _onCourseTap(context),
        child: Container(
            decoration: BoxDecoration(color: bgColorRow, border: noteBorder),
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.title, style: titleStyle),
              Text('${course.location} - ${course.description}',
                  style: subheadStyle),
              Text(course.dateForDisplay(), style: cationStyle),
            ])));
  }
}
