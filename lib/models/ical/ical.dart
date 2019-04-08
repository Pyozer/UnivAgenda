import 'package:myagenda/models/ical/vevent.dart';

class Ical {
  List<VEvent> vevents;
  bool success;

  Ical({this.vevents, this.success});

  factory Ical.fromJson(Map<String, dynamic> json) => Ical(
        vevents: List<VEvent>.from(
          (json["data"] ?? []).map((x) => VEvent.fromJson(x)),
        ),
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "vevents": List<dynamic>.from((vevents ?? []).map((x) => x.toJson())),
        "success": success,
      };
}
