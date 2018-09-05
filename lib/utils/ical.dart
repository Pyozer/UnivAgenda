import 'package:myagenda/models/ical_model.dart';

class Ical {
  static List<IcalModel> parseToIcal(String icalData) {
    List<String> lines = icalData.split("\n");

    Duration timezoneOffset = DateTime.now().timeZoneOffset;

    List<IcalModel> events = List();
    IcalModel event;

    lines.forEach((line) {
      if (line.startsWith('BEGIN:VEVENT')) {
        event = IcalModel();
      } else if (line.startsWith('DTSTART')) {
        event.dtstart = _getDateValue(line).add(timezoneOffset);
      } else if (line.startsWith('DTEND')) {
        event.dtend = _getDateValue(line).add(timezoneOffset);
      } else if (line.startsWith('SUMMARY')) {
        event.summary = _getValue(line);
      } else if (line.startsWith('LOCATION')) {
        event.location = _getValue(line);
      } else if (line.startsWith('DESCRIPTION')) {
        String description = _getValue(line);

        event.description = description
            .replaceAll(RegExp(r'\\n'), ' ')
            .split('(Export')[0]
            .replaceAll(RegExp(r'\s\s+'), ' ')
            .trim();
      } else if (line.startsWith('UID')) {
        event.uid = _getValue(line);
      } else if (line.startsWith('END:VEVENT')) {
        events.add(event);
      }
    });

    return events;
  }

  static _getValue(String line) {
    final index =
        line.indexOf(":"); // Gets the first index where a space occours
    return line.substring(index + 1); // Gets the value part
  }

  static DateTime _getDateValue(String line) {
    return DateTime.parse(_getValue(line).toString().substring(0, 15));
  }
}
