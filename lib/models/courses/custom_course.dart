import 'dart:convert';
import 'dart:ui';

import 'package:device_calendar/device_calendar.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/courses/weekday.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/utils/functions.dart';

class CustomCourse extends Course {
  List<WeekDay> weekdaysRepeat;
  Calendar syncCalendar;

  CustomCourse(
    String uid,
    String title,
    String description,
    String location,
    DateTime dateStart,
    DateTime dateEnd, {
    List<Note> notes,
    Color color,
    this.weekdaysRepeat,
    this.syncCalendar,
  }) : super(uid, title, description, location, dateStart, dateEnd,
            notes: notes, color: color) {
    this.weekdaysRepeat ??= [];
  }

  factory CustomCourse.fromJsonStr(String jsonStr) {
    Map courseMap = json.decode(jsonStr);
    return CustomCourse.fromJson(courseMap);
  }

  factory CustomCourse.fromJson(Map<String, dynamic> json) {
    Course course = Course.fromJson(json);

    List<WeekDay> listWeekDays = [];
    if (json['weekdays_repeat'] != null &&
        json['weekdays_repeat'].trim() != "") {
      List<int> weekDays = json['weekdays_repeat']
          .toString()
          .split(',')
          .map((value) => int.parse(value))
          .toList();

      weekDays.forEach((weekDay) {
        listWeekDays.add(WeekDay.fromValue(weekDay));
      });
    }

    return CustomCourse(
      course.uid,
      course.title,
      course.description,
      course.location,
      course.dateStart,
      course.dateEnd,
      color: course.color,
      weekdaysRepeat: listWeekDays,
      syncCalendar: json['sync_calendar'] != null
          ? Calendar.fromJson(json['sync_calendar'])
          : null,
    );
  }

  factory CustomCourse.copy(CustomCourse cc) {
    CustomCourse copied = CustomCourse.fromJson(cc.toJson());
    List notesCopied = json.decode(json.encode(cc.notes));
    copied.notes = notesCopied.map((e) => Note.fromJson(e)).toList();
    return copied;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = super.toJson();

    List<int> weekDaysIndex = [];
    weekdaysRepeat.forEach((weekDay) {
      weekDaysIndex.add(weekDay.value);
    });
    if (weekDaysIndex.length > 0)
      jsonMap['weekdays_repeat'] = weekDaysIndex.join(',');
    else
      jsonMap['weekdays_repeat'] = "";

    jsonMap['sync_calendar'] = syncCalendar?.toJson() ?? null;

    return jsonMap;
  }

  bool isRecurrentEvent() => (weekdaysRepeat?.length ?? 0) > 0;

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCourse &&
          super == (other) &&
          runtimeType == other.runtimeType &&
          listEqualsNotOrdered(weekdaysRepeat, other.weekdaysRepeat);

  @override
  int get hashCode => super.hashCode ^ weekdaysRepeat.hashCode;
}
