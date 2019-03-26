import 'package:myagenda/models/ical/vcalendar.dart';

class Ical {
  List<VCalendar> vcalendar;
  bool success;

  Ical({this.vcalendar, this.success});

  factory Ical.fromJson(Map<String, dynamic> json) => Ical(
        vcalendar: List<VCalendar>.from(
          (json["vcalendar"] ?? []).map((x) => VCalendar.fromJson(x)),
        ),
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "vcalendar": List<dynamic>.from(
          (vcalendar ?? []).map((x) => x.toJson()),
        ),
        "success": success,
      };
}
