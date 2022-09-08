class Note {
  String courseUid;
  String text;

  Note({required this.courseUid, required this.text});

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
