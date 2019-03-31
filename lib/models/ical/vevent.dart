class VEvent {
  DateTime dtstart;
  DateTime dtend;
  DateTime dtstamp;
  String uid;
  DateTime created;
  String description;
  DateTime lastModified;
  String location;
  String sequence;
  String status;
  String summary;
  String transp;

  VEvent({
    this.dtstart,
    this.dtend,
    this.dtstamp,
    this.uid,
    this.created,
    this.description,
    this.lastModified,
    this.location,
    this.sequence,
    this.status,
    this.summary,
    this.transp,
  });

  factory VEvent.fromJson(Map<String, dynamic> json) => VEvent(
        dtstart: DateTime.parse(json["dtstart"]),
        dtend: DateTime.parse(json["dtend"]),
        dtstamp: json["dtstamp"] != null
          ? DateTime.parse(json["dtstamp"])
          : null,
        uid: json["uid"],
        created: json["created"] != null
          ? DateTime.parse(json["created"])
          : null,
        description: json["description"],
        lastModified: json["last-modified"] != null
            ? DateTime.parse(json["last-modified"])
            : null,
        location: json["location"],
        sequence: json["sequence"],
        status: json["status"],
        summary: json["summary"],
        transp: json["transp"],
      );

  Map<String, dynamic> toJson() => {
        "dtstart": dtstart.toIso8601String(),
        "dtend": dtend.toIso8601String(),
        "dtstamp": dtstamp?.toIso8601String(),
        "uid": uid,
        "created": created?.toIso8601String(),
        "description": description,
        "last-modified": lastModified?.toIso8601String(),
        "location": location,
        "sequence": sequence,
        "status": status,
        "summary": summary,
        "transp": transp,
      };
}
