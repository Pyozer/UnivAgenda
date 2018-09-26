import 'dart:ui';

import 'package:myagenda/utils/date.dart';

abstract class BaseCourse {
  String dateForDisplay([Locale locale]);
}

class CourseHeader extends BaseCourse {
  DateTime date;

  CourseHeader(this.date);

  @override
  String dateForDisplay([Locale locale]) {
    return Date.dateFromNow(date, locale);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseHeader &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;
}
