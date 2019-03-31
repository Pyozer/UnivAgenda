import 'dart:convert';

class Note {
  String courseUid;
  String text;

  Note({this.courseUid, this.text})
      : assert(text != null),
        assert(courseUid != null);

  factory Note.fromJsonStr(String jsonStr) {
    Map noteMap = json.decode(jsonStr);
    return Note.fromJson(noteMap);
  }

  factory Note.fromJson(Map<String, dynamic> json) =>
      Note(courseUid: json['courseUid'], text: json['text']);

  Map<String, dynamic> toJson() => {'courseUid': courseUid, 'text': text};

  @override
  String toString() => toJson().toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          courseUid == other.courseUid &&
          text == other.text;

  @override
  int get hashCode => courseUid.hashCode ^ text.hashCode;
}
