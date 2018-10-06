import 'dart:convert';
import 'dart:ui';

import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/courses/weekday.dart';
import 'package:myagenda/models/note.dart';

class CustomCourse extends Course {
  List<WeekDay> weekdaysRepeat;

  CustomCourse(
    String uid,
    String title,
    String description,
    String location,
    DateTime dateStart,
    DateTime dateEnd, {
    List<Note> notes = const [],
    Color color,
    this.weekdaysRepeat = const [],
  }) : super(uid, title, description, location, dateStart, dateEnd,
            notes: notes, color: color);

  factory CustomCourse.fromJsonStr(String jsonStr) {
    Map courseMap = json.decode(jsonStr);
    return CustomCourse.fromJson(courseMap);
  }

  factory CustomCourse.fromJson(Map<String, dynamic> jsonInput) {
    Color courseColor;
    if (jsonInput['color'] != null) {
      courseColor = Color(jsonInput['color']);
    }

    List<WeekDay> listWeekDays = [];
    if (jsonInput['weekdays_repeat'] != null &&
        jsonInput['weekdays_repeat'].trim() != "") {
      List<int> weekDays = jsonInput['weekdays_repeat']
          .toString()
          .split(',')
          .map((value) => int.parse(value))
          .toList();

      weekDays.forEach((weekDay) {
        listWeekDays.add(WeekDay.fromValue(weekDay));
      });
    }

    return CustomCourse(
      jsonInput['uid'],
      jsonInput['title'],
      jsonInput['description'],
      jsonInput['location'],
      DateTime.fromMillisecondsSinceEpoch(jsonInput['date_start']),
      DateTime.fromMillisecondsSinceEpoch(jsonInput['date_end']),
      color: courseColor,
      weekdaysRepeat: listWeekDays,
    );
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

    return jsonMap;
  }

  bool isRecurrentEvent() => weekdaysRepeat.length > 0;

  @override
  String toString() {
    return toJson().toString();
  }
}
