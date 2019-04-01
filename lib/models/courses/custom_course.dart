import 'dart:convert';
import 'dart:ui';

import 'package:device_calendar/device_calendar.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/courses/weekday.dart';
import 'package:myagenda/models/courses/note.dart';
import 'package:myagenda/utils/functions.dart';

class CustomCourse extends Course {
  List<WeekDay> weekdaysRepeat;
  Calendar syncCalendar;

  CustomCourse({
    String uid,
    String title,
    String description,
    String location,
    DateTime dateStart,
    DateTime dateEnd,
    List<Note> notes,
    Color color,
    this.weekdaysRepeat,
    this.syncCalendar,
  }) : super(
          uid: uid,
          title: title,
          description: description,
          location: location,
          dateStart: dateStart,
          dateEnd: dateEnd,
          notes: notes,
          color: color,
        ) {
    this.weekdaysRepeat ??= [];
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
    Calendar calendar = json['sync_calendar'] != null
        ? Calendar.fromJson(json['sync_calendar'])
        : null;

    return CustomCourse(
      uid: course.uid,
      title: course.title,
      description: course.description,
      location: course.location,
      dateStart: course.dateStart,
      dateEnd: course.dateEnd,
      color: course.color,
      weekdaysRepeat: listWeekDays,
      syncCalendar: calendar,
    );
  }

  factory CustomCourse.copy(CustomCourse cc) {
    CustomCourse copied = CustomCourse.fromJson(cc.toJson());
    List notesCopied = json.decode(json.encode(cc.notes));
    copied.notes = notesCopied.map((e) => Note.fromJson(e)).toList();
    return copied;
  }

  factory CustomCourse.empty() =>
      CustomCourse(uid: "", title: "", description: "", location: "");

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = super.toJson();

    List<int> weekDaysIndex = [];
    weekdaysRepeat.forEach((weekDay) {
      weekDaysIndex.add(weekDay.value);
    });
    if (weekDaysIndex.isNotEmpty)
      jsonMap['weekdays_repeat'] = weekDaysIndex.join(',');
    else
      jsonMap['weekdays_repeat'] = "";

    jsonMap['sync_calendar'] = syncCalendar?.toJson() ?? null;

    return jsonMap;
  }

  bool isRecurrentEvent() => (weekdaysRepeat?.length ?? 0) > 0;

  @override
  String toString() => toJson().toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCourse &&
          super == (other) &&
          runtimeType == other.runtimeType &&
          listEqualsNotOrdered(weekdaysRepeat, other.weekdaysRepeat) &&
          syncCalendar?.id == other.syncCalendar?.id;

  @override
  int get hashCode =>
      super.hashCode ^ weekdaysRepeat.hashCode ^ syncCalendar.hashCode;
}
