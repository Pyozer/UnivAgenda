class NoteCourse {
  String courseUid;
  String text = "";
  DateTime dateExpiration;

  NoteCourse({this.courseUid, this.text, this.dateExpiration});

  bool isExpired() {
    return dateExpiration.isBefore(DateTime.now());
  }
}
