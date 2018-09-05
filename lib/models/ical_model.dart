class IcalModel {
  DateTime dtstart;
  DateTime dtend;
  String summary;
  String location;
  String description;
  String uid;

  IcalModel(
      {this.dtstart,
      this.dtend,
      this.summary,
      this.location,
      this.description,
      this.uid});

  @override
  String toString() {
    return '{dtstart: $dtstart, dtend: $dtend, summary: $summary, location: $location, description: $description, uid: $uid}';
  }
}
