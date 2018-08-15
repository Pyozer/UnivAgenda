import 'dart:ui';

import 'package:myagenda/models/ical_model.dart';
import 'package:myagenda/models/note_cours.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/functions.dart';

abstract class BaseCourse {
  String dateForDisplay([Locale locale]);
}

class CourseHeader implements BaseCourse {
  DateTime date;

  CourseHeader(this.date);

  @override
  String dateForDisplay([Locale locale]) {
    return Date.dateFromNow(date, locale);
  }
}

class Course implements BaseCourse {
  String uid;
  String title;
  String description;
  String location;
  List<NoteCourse> note;
  DateTime dateStart;
  DateTime dateEnd;

  Course(this.uid, this.title, this.description, this.location, this.dateStart,
      this.dateEnd);

  bool hasNote() {
    return (note != null && note.length > 0);
  }

  bool isFinish() {
    return dateEnd.isBefore(DateTime.now());
  }

  bool isStarted() {
    return dateStart.isAfter(DateTime.now()) && !isFinish();
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

    return '$startTime à $endTime';
  }

  factory Course.fromIcalModel(IcalModel ical) {
    return Course(
        ical.uid,
        ical.summary,
        ical.description,
        ical.location,
        DateTime.parse(ical.dtstart.substring(0, ical.dtstart.length - 2)),
        DateTime.parse(ical.dtend.substring(0, ical.dtend.length - 2)));
  }
}
