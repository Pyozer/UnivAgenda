import 'package:myagenda/models/ical/vevent.dart';

class VCalendar {
  String prodid;
  String version;
  String calscale;
  String method;
  List<VEvent> vevent;

  VCalendar({
    this.prodid,
    this.version,
    this.calscale,
    this.method,
    this.vevent,
  });

  factory VCalendar.fromJson(Map<String, dynamic> json) => VCalendar(
        prodid: json["prodid"],
        version: json["version"],
        calscale: json["calscale"],
        method: json["method"],
        vevent: List<VEvent>.from(
          (json["vevent"] ?? []).map((x) => VEvent.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "prodid": prodid,
        "version": version,
        "calscale": calscale,
        "method": method,
        "vevent": List<dynamic>.from(vevent.map((x) => x.toJson())),
      };
}
