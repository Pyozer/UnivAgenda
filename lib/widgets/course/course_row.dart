import 'package:flutter/material.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/screens/detail_course/detail_course.dart';
import 'package:myagenda/utils/custom_route.dart';

class CourseRow extends StatelessWidget {
  final Course course;
  final Color noteColor;

  CourseRow(
      {Key key,
      this.course,
      this.noteColor = const Color(PrefKey.defaultNoteColor)})
      : super(key: key);

  void _onCourseTap(BuildContext context) {
    Navigator.of(context).push(
      CustomRoute<Course>(
          builder: (context) => DetailCourse(course: course),
          fullscreenDialog: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Color bgColorRow;
    if (course.color != null)
      bgColorRow = course.color;
    else if (course.isExam()) bgColorRow = Colors.red[600];

    final noteIndicator = course.hasNote()
        ? Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(25.0),
            child: Container(
              decoration: BoxDecoration(
                color: noteColor,
                borderRadius: BorderRadius.circular(40.0),
              ),
              width: 14.0,
              height: 14.0,
            ),
          )
        : Container(width: 14.0, height: 14.0);

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: InkWell(
        onTap: () => _onCourseTap(context),
        child: Container(
          decoration: BoxDecoration(color: bgColorRow),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${course.location} - ${course.description}',
                      style: const TextStyle(fontSize: 13.0),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      course.dateForDisplay(),
                      style: textTheme.caption.copyWith(fontSize: 13.0),
                    )
                  ],
                ),
              ),
              noteIndicator
            ],
          ),
        ),
      ),
    );
  }
}
