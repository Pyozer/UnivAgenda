import 'package:myagenda/models/NoteCours.dart';
import 'package:myagenda/utils/ical.dart';

class Cours {

  String uid;
  String title;
  String description;
  NoteCours note;
  DateTime dateStart;
  DateTime dateEnd;
  bool isExam;

  Cours(
      {this.uid,
      this.title,
      this.description,
      this.dateStart,
      this.dateEnd,
      this.isExam});

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

  bool isHeader() {
    return (description.isEmpty && dateStart == null);
  }

  static Cours fromIcalModel(IcalModel ical) {
    return new Cours(
      uid: ical.uid,
      dateStart: DateTime.parse(ical.dtstart.substring(0, ical.dtstart.length - 2)),
      dateEnd: DateTime.parse(ical.dtend.substring(0, ical.dtend.length - 2)),
      title: ical.summary,
      description: ical.description,
      isExam: ical.description.contains(new RegExp('exam'))
    );
  }
}
