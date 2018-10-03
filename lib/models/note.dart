import 'dart:convert';

class Note {
  DateTime dateCreation;
  String courseUid;
  String text;

  Note({this.courseUid, this.text, this.dateCreation})
      : assert(text != null),
        assert(courseUid != null) {
    if (dateCreation == null) dateCreation = DateTime.now();
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
      );

  Map<String, dynamic> toJson() => {
        'courseUid': courseUid,
        'text': text,
        'date_creation': dateCreation.millisecondsSinceEpoch
      };

  @override
  String toString() => this.toJson().toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          dateCreation == other.dateCreation &&
          courseUid == other.courseUid &&
          text == other.text;

  @override
  int get hashCode =>
      dateCreation.hashCode ^
      courseUid.hashCode ^
      text.hashCode;
}
