class Note {
  DateTime dateCreation;
  String courseUid;
  String text;
  DateTime dateExpiration;

  Note({this.courseUid, this.text, this.dateExpiration, this.dateCreation})
      : assert(text != null),
        assert(courseUid != null),
        assert(dateExpiration != null) {
    if(dateCreation == null)
      dateCreation = DateTime.now();
  }
        
  bool isExpired() {
    return dateExpiration.isBefore(DateTime.now());
  }

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    courseUid: json['courseUid'],
    text: json['text'],
    dateExpiration: DateTime.fromMillisecondsSinceEpoch(json['date_expiration']),
    dateCreation: DateTime.fromMillisecondsSinceEpoch(json['date_creation']),
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
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Note typedOther = other;
    return (dateCreation.compareTo(dateCreation) == 0 && dateExpiration.compareTo(dateExpiration) == 0 && courseUid == typedOther.courseUid && text == typedOther.text);
  }

  @override
  int get hashCode => this.hashCode;
}
