import 'package:myagenda/models/ical_model.dart';
import 'package:myagenda/models/note_cours.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/functions.dart';

abstract class BaseCourse {
  String dateForDisplay();
}

class CourseHeader implements BaseCourse {
  DateTime date;

  CourseHeader(this.date);

  @override
  String dateForDisplay() {
    return Date.dateFromNow(date);
  }
}

class Course implements BaseCourse {
  String uid;
  String title;
  String description;
  String location;
  NoteCourse note;
  DateTime dateStart;
  DateTime dateEnd;

  Course(this.uid, this.title, this.description, this.location, this.dateStart,
      this.dateEnd);

  bool hasNote() {
    return (note != null && !note.text.isNotEmpty);
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
  String dateForDisplay() {
    final startH = twoDigits(dateStart.hour);
    final startM = twoDigits(dateStart.minute);
    final endH = twoDigits(dateEnd.hour);
    final endM = twoDigits(dateEnd.minute);

    return '${startH}h$startM à ${endH}h$endM';
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
