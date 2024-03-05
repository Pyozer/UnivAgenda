import 'dart:convert';
import 'dart:ui';

import 'course.dart';
import 'weekday.dart';
import 'note.dart';
import '../../utils/functions.dart';

class CustomCourse extends Course {
  late List<WeekDay> weekdaysRepeat;

  CustomCourse({
    required String uid,
    required String title,
    required String description,
    String? location,
    required DateTime dateStart,
    required DateTime dateEnd,
    List<Note>? notes,
    Color? color,
    List<WeekDay>? weekdaysRepeat,
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
    this.weekdaysRepeat = weekdaysRepeat ?? [];
  }

  factory CustomCourse.fromJson(Map<String, dynamic> json) {
    Course course = Course.fromJson(json);

    List<WeekDay> listWeekDays = [
      if ((json['weekdays_repeat'] ?? '').trim() != '')
        ...json['weekdays_repeat']
            .toString()
            .split(',')
            .map((value) => WeekDay.fromValue(int.parse(value))),
    ];

    return CustomCourse(
      uid: course.uid,
      title: course.title,
      description: course.description,
      location: course.location,
      dateStart: course.dateStart,
      dateEnd: course.dateEnd,
      color: course.color,
      weekdaysRepeat: listWeekDays,
    );
  }

  factory CustomCourse.copy(CustomCourse cc) {
    CustomCourse copied = CustomCourse.fromJson(cc.toJson());
    List notesCopied = json.decode(json.encode(cc.allNotes));
    copied.allNotes = notesCopied.map((e) => Note.fromJson(e)).toList();
    return copied;
  }

  factory CustomCourse.empty(DateTime dateStart, DateTime dateEnd) =>
      CustomCourse(
        uid: '',
        title: '',
        description: '',
        location: '',
        dateStart: dateStart,
        dateEnd: dateEnd,
      );

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = super.toJson();

    if (weekdaysRepeat.isNotEmpty) {
      jsonMap['weekdays_repeat'] =
          weekdaysRepeat.map((wd) => wd.value).join(',');
    } else {
      jsonMap['weekdays_repeat'] = '';
    }

    return jsonMap;
  }

  bool isRecurrentEvent() => weekdaysRepeat.isNotEmpty;

  @override
  String toString() => toJson().toString();

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
