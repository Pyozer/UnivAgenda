import 'package:myagenda/models/IcalModel.dart';
import 'package:myagenda/models/NoteCours.dart';
import 'package:myagenda/utils/date.dart';

String twoDigits(int number) {
  return number.toString().padLeft(2, '0');
}

abstract class BaseCours {
  String dateForDisplay();
}

class CoursHeader implements BaseCours {
  DateTime date;

  CoursHeader(this.date);

  @override
  String dateForDisplay() {
    return Date.dateFromNow(date);
  }
}

class Cours implements BaseCours {
  String uid;
  String title;
  String description;
  String location;
  NoteCours note;
  DateTime dateStart;
  DateTime dateEnd;

  Cours(this.uid, this.title, this.description, this.location, this.dateStart,
      this.dateEnd);

  bool hasNote() {
    return (note != null && !note.text.isNotEmpty);
  }

  bool isFinish() {
    return dateEnd.isBefore(new DateTime.now());
  }

  bool isStarted() {
    return dateStart.isAfter(new DateTime.now()) && !isFinish();
  }

  int getMinutesBeforeStart() {
    int minutes = dateStart.difference(dateEnd).inMinutes;
    return minutes > 0 ? minutes : 0;
  }

  bool isExam() {
    return title.contains(new RegExp('exam', caseSensitive: false));
  }

  @override
  String dateForDisplay() {
    final startH = twoDigits(dateStart.hour);
    final startM = twoDigits(dateStart.minute);
    final endH = twoDigits(dateEnd.hour);
    final endM = twoDigits(dateEnd.minute);

    return '${startH}h$startM à ${endH}h$endM';
  }

  static Cours fromIcalModel(IcalModel ical) {
    return new Cours(
        ical.uid,
        ical.summary,
        ical.description,
        ical.location,
        DateTime.parse(ical.dtstart.substring(0, ical.dtstart.length - 2)),
        DateTime.parse(ical.dtend.substring(0, ical.dtend.length - 2)));
  }
}
