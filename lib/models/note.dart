class Note {
  String courseUid;
  String text;
  DateTime dateExpiration;

  Note({this.courseUid, this.text, this.dateExpiration})
      : assert(text != null),
        assert(courseUid != null);

  bool isExpired() {
    return dateExpiration.isBefore(DateTime.now());
  }
}
