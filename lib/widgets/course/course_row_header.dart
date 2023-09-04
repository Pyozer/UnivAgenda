import 'package:flutter/material.dart';

import '../../models/courses/base_course.dart';

class CourseRowHeader extends StatelessWidget {
  final CourseHeader coursHeader;

  const CourseRowHeader({Key? key, required this.coursHeader})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
        top: 20.0,
      ),
      child: Text(
        coursHeader.dateForDisplay(),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22.0),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
