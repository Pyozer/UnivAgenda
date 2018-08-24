import 'package:myagenda/models/ical_model.dart';

class Ical {

  static List<IcalModel> parseToIcal(String icalData) {
    List<String> lines = icalData.split("\n");

    List<IcalModel> events = List();
    IcalModel event;

    lines.forEach((line) {
      if (line.startsWith('BEGIN:VEVENT')) {
        event = IcalModel();
      } else if (line.startsWith('DTSTART')) {
        event.dtstart = _getValue(line);
      } else if (line.startsWith('DTEND')) {
        event.dtend = _getValue(line);
      } else if (line.startsWith('SUMMARY')) {
        event.summary = _getValue(line);
      } else if (line.startsWith('LOCATION')) {
        event.location = _getValue(line);
      } else if (line.startsWith('DESCRIPTION')) {
        String description = _getValue(line);

        /*final remove = ['DUT', 'S1', 'S2', 'S3', 'S4'];
        remove.forEach(
            (value) => description = description.replaceAll(value, ''));*/

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
    final index = line.indexOf(":"); // Gets the first index where a space occours
    return line.substring(index + 1); // Gets the value part
  }
}