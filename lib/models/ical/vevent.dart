class VEvent {
  DateTime dtstart;
  DateTime dtend;
  DateTime? dtstamp;
  String uid;
  DateTime? created;
  String description;
  DateTime? lastModified;
  String location;
  String summary;

  VEvent({
    required this.dtstart,
    required this.dtend,
    this.dtstamp,
    required this.uid,
    this.created,
    required this.description,
    this.lastModified,
    this.location = '',
    required this.summary,
  });

  factory VEvent.fromJson(Map<String, dynamic> json) => VEvent(
        dtstart: DateTime.parse(json["dtstart"]),
        dtend: DateTime.parse(json["dtend"]),
        dtstamp:
            json["dtstamp"] != null ? DateTime.parse(json["dtstamp"]) : null,
        uid: json["uid"],
        created:
            json["created"] != null ? DateTime.parse(json["created"]) : null,
        description: json["description"],
        lastModified: json["lastmodified"] != null
            ? DateTime.parse(json["lastmodified"])
            : null,
        location: json["location"],
        summary: json["summary"],
      );

  Map<String, dynamic> toJson() => {
        "dtstart": dtstart.toIso8601String(),
        "dtend": dtend.toIso8601String(),
        "dtstamp": dtstamp?.toIso8601String(),
        "uid": uid,
        "created": created?.toIso8601String(),
        "description": description,
        "lastmodified": lastModified?.toIso8601String(),
        "location": location,
        "summary": summary,
      };
}
