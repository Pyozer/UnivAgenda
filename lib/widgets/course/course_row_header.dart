import 'package:flutter/material.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/utils/translations.dart';

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
        bottom: 16.0,
        top: 20.0,
      ),
      child: Text(
        coursHeader.dateForDisplay(Translations.of(context).locale),
        style: textStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
