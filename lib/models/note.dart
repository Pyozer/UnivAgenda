import 'dart:convert';

class Note {
  DateTime dateCreation;
  String courseUid;
  String text;
  DateTime dateExpiration;

  Note({this.courseUid, this.text, this.dateExpiration, this.dateCreation})
      : assert(text != null),
        assert(courseUid != null),
        assert(dateExpiration != null) {
    if (dateCreation == null) dateCreation = DateTime.now();
  }

  bool isExpired() {
    return dateExpiration.isBefore(DateTime.now());
  }

  factory Note.fromJsonStr(String jsonStr) {
    Map noteMap = json.decode(jsonStr);
    return Note.fromJson(noteMap);
  }

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        courseUid: json['courseUid'],
        text: json['text'],
        dateExpiration:
            DateTime.fromMillisecondsSinceEpoch(json['date_expiration']),
        dateCreation:
            DateTime.fromMillisecondsSinceEpoch(json['date_creation']),
      );

  Map<String, dynamic> toJson() => {
        'courseUid': courseUid,
        'text': text,
        'date_expiration': dateExpiration.millisecondsSinceEpoch,
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
          text == other.text &&
          dateExpiration == other.dateExpiration;

  @override
  int get hashCode =>
      dateCreation.hashCode ^
      courseUid.hashCode ^
      text.hashCode ^
      dateExpiration.hashCode;
}
