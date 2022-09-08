import 'package:univagenda/models/ical/vevent.dart';

class Ical {
  List<VEvent> vevents;

  Ical({this.vevents = const []});

  factory Ical.fromJson(Map<String, dynamic> json) => Ical(
        vevents: List<VEvent>.from(
          (json["vevents"] ?? []).map((x) => VEvent.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "vevents": List<dynamic>.from(vevents.map((x) => x.toJson())),
      };
}
