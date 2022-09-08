class Hidden {
  String courseUid;
  String title;

  Hidden({required this.courseUid, required this.title});

  factory Hidden.fromJson(Map<String, dynamic> json) =>
      Hidden(courseUid: json['courseUid'], title: json['title']);

  Map<String, dynamic> toJson() => {'courseUid': courseUid, 'title': title};

  @override
  String toString() => toJson().toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hidden &&
          runtimeType == other.runtimeType &&
          courseUid == other.courseUid &&
          title == other.title;

  @override
  int get hashCode => courseUid.hashCode ^ title.hashCode;
}
