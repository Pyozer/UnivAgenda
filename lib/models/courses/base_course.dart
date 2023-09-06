abstract class BaseCourse {}

class CourseHeader extends BaseCourse {
  DateTime date;

  CourseHeader(this.date);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseHeader &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;
}
