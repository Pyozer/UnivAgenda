import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'course.dart';

class CourseDataSource extends CalendarDataSource<Course> {
  bool _isGenColor = false;
  late Color _defaultBgColor;

  CourseDataSource(List<Course> source, bool isGenColor, Color defaultBgColor) {
    appointments = source;
    _isGenColor = isGenColor;
    _defaultBgColor = defaultBgColor;
  }

  Course getEvent(int index) {
    return appointments![index];
  }

  @override
  DateTime getStartTime(int index) {
    return getEvent(index).dateStart;
  }

  @override
  DateTime getEndTime(int index) {
    return getEvent(index).dateEndCalc;
  }

  @override
  Object? getId(int index) {
    return getEvent(index).uid;
  }

  @override
  String getSubject(int index) {
    return getEvent(index).title;
  }

  @override
  String? getNotes(int index) {
    return getEvent(index).allNotes.map((e) => e.text).join(', ');
  }

  @override
  Color getColor(int index) {
    return getEvent(index).getBgColor(_isGenColor) ?? _defaultBgColor;
  }

  @override
  bool isAllDay(int index) {
    return getEvent(index).isAllDay();
  }
}
