import 'dart:ui';

import 'package:myagenda/models/courses/base_course.dart';
import 'package:myagenda/models/ical_model.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/utils/date.dart';

class Course extends BaseCourse {
  String uid;
  String title;
  String description;
  String location;
  List<Note> notes;
  DateTime dateStart;
  DateTime dateEnd;
  Color color;
  bool isCustomEvent;

  Course(this.uid, this.title, this.description, this.location, this.dateStart,
      this.dateEnd,
      {this.notes = const [], this.color});

  bool hasNote() {
    return (notes != null && notes.length > 0);
  }

  bool isFinish() {
    return dateEnd.isBefore(DateTime.now());
  }

  bool isStarted() {
    return dateStart.isBefore(DateTime.now()) && !isFinish();
  }

  int getMinutesBeforeStart() {
    int minutes = dateStart.difference(dateEnd).inMinutes;
    return minutes > 0 ? minutes : 0;
  }

  bool isExam() {
    return title.contains(RegExp('exam', caseSensitive: false));
  }

  @override
  String dateForDisplay([Locale locale]) {
    final startTime = Date.extractTime(dateStart, locale);
    final endTime = Date.extractTime(dateEnd, locale);

    return '$startTime - $endTime';
  }

  factory Course.fromIcalModel(IcalModel ical) => Course(
      ical.uid?.trim(),
      ical.summary?.trim(),
      ical.description?.trim(),
      ical.location?.trim(),
      ical.dtstart,
      ical.dtend);

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        json['uid'],
        json['title'],
        json['description'],
        json['location'],
        DateTime.fromMillisecondsSinceEpoch(json['date_start']),
        DateTime.fromMillisecondsSinceEpoch(json['date_end']),
        color: Color(json['color']),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'title': title,
        'description': description,
        'location': location,
        'date_start': dateStart.millisecondsSinceEpoch,
        'date_end': dateEnd.millisecondsSinceEpoch,
        'color': color?.value
      };

  @override
  String toString() {
    return 'Course{uid: $uid, title: $title, description: $description, location: $location, notes: $notes, dateStart: $dateStart, dateEnd: $dateEnd, color: $color}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
