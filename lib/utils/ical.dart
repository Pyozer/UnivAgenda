import 'package:myagenda/models/ical_model.dart';

const String BEGINVEVENT = "BEGIN:VEVENT";
const String ENDVEVENT = "END:VEVENT";
const String DTSTART = "DTSTART";
const String DTEND = "DTEND";
const String SUMMARY = "SUMMARY";
const String DESCRIPTION = "DESCRIPTION";
const String LOCATION = "LOCATION";
const String UID = "UID";

class Ical {

  static List<IcalModel> parseToIcal(String icalData) {
    List<String> lines = icalData.split("\n");

    Duration timezoneOffset = DateTime.now().timeZoneOffset;

    List<IcalModel> events = List();
    IcalModel event;

    String lastProp;

    lines.forEach((line) {
      if (line.startsWith(BEGINVEVENT)) {
        event = IcalModel();
        lastProp = BEGINVEVENT;
      } else if (line.startsWith(ENDVEVENT)) {
        events.add(event);
        lastProp = ENDVEVENT;
      } else if (line.startsWith(DTSTART)) {
        event.dtstart = _getDateValue(line).add(timezoneOffset);
        lastProp = DTSTART;
      } else if (line.startsWith(DTEND)) {
        event.dtend = _getDateValue(line).add(timezoneOffset);
        lastProp = DTEND;
      } else if (line.startsWith(SUMMARY)) {
        event.summary = _getValue(line);
        lastProp = SUMMARY;
      } else if (line.startsWith(LOCATION)) {
        event.location = _getValue(line);
        lastProp = LOCATION;
      } else if (line.startsWith(UID)) {
        event.uid = _getValue(line);
        lastProp = UID;
      } else if (line.startsWith(DESCRIPTION) || lastProp == DESCRIPTION) {
        String description = _getValue(line);

        event.description += description
            .replaceAll(RegExp(r'\\n'), ' ')
            .split('(Export')[0]
            .replaceAll(RegExp(r'\s\s+'), ' ')
            .trim();

        lastProp = DESCRIPTION;
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
