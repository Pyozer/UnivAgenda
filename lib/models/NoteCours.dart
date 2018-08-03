class NoteCours {
  String coursUid;
  String text = "";
  DateTime dateExpiration;

  NoteCours({this.coursUid, this.text, this.dateExpiration});

  bool isExpired() {
    return dateExpiration.isBefore(new DateTime.now());
  }
}
