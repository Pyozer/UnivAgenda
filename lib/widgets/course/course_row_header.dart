import 'package:flutter/material.dart';
import 'package:myagenda/models/courses/base_course.dart';

class CourseRowHeader extends StatelessWidget {
  final CourseHeader coursHeader;

  const CourseRowHeader({Key key, this.coursHeader}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.title;

    return Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 5.0,
        top: 20.0,
      ),
      child: Text(
        coursHeader.dateForDisplay(
          Locale(Localizations.localeOf(context).languageCode ?? 'en'),
        ),
        style: textStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
