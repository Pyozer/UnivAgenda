import 'dart:convert';

class Note {
  DateTime dateCreation;
  String courseUid;
  String text;
  DateTime dateEnd;

  Note({this.courseUid, this.text, this.dateCreation, this.dateEnd})
      : assert(text != null),
        assert(courseUid != null) {
    dateCreation ??= DateTime.now();
  }

  factory Note.fromJsonStr(String jsonStr) {
    Map noteMap = json.decode(jsonStr);
    return Note.fromJson(noteMap);
  }

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        courseUid: json['courseUid'],
        text: json['text'],
        dateCreation:
            DateTime.fromMillisecondsSinceEpoch(json['date_creation']),
        dateEnd: json['date_end'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['date_end'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'courseUid': courseUid,
        'text': text,
        'date_creation': dateCreation.millisecondsSinceEpoch,
        'date_end': dateEnd?.millisecondsSinceEpoch ?? null,
      };

  @override
  String toString() => toJson().toString();

  bool isNoteExpired() {
    if (dateEnd == null) return false;
    return dateEnd.isBefore(DateTime.now());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          dateCreation == other.dateCreation &&
          dateEnd == other.dateEnd &&
          courseUid == other.courseUid &&
          text == other.text;

  @override
  int get hashCode =>
      dateCreation.hashCode ^
      dateEnd.hashCode ^
      courseUid.hashCode ^
      text.hashCode;
}
