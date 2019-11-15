import 'package:univagenda/utils/date.dart';

abstract class BaseCourse {
  String dateForDisplay();
}

class CourseHeader extends BaseCourse {
  DateTime date;

  CourseHeader(this.date);

  @override
  String dateForDisplay() {
    return Date.dateFromNow(date);
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
