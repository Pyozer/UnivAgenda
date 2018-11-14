import 'package:flutter/services.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:time_machine/time_machine.dart';

const String BEGINVEVENT = "BEGIN:VEVENT";
const String ENDVEVENT = "END:VEVENT";
const String DTSTART = "DTSTART";
const String DTEND = "DTEND";
const String SUMMARY = "SUMMARY";
const String DESCRIPTION = "DESCRIPTION";
const String LOCATION = "LOCATION";
const String UID = "UID";

class Ical {
  static bool isValidIcal(String ical) {
    if (ical != null && ical.trimLeft().startsWith("BEGIN:VCALENDAR")) if (ical
        .trimRight()
        .endsWith("END:VCALENDAR")) return true;

    return false;
  }

  static Future<List<Course>> parseToIcal(String icalData) async {
    if (icalData == null || icalData.trim().length == 0) return [];

    if (!isValidIcal(icalData)) throw ("Wrong ICS file format !");

    List<String> lines = icalData.split("\n");
    List<Course> events = [];
    Course event;

    String lastProp;

    lines.forEach((line) {
      if (line.startsWith(BEGINVEVENT)) {
        event = Course.empty();
        lastProp = BEGINVEVENT;
      } else if (line.startsWith(ENDVEVENT)) {
        // Remove exported indicator of description
        event.description = capitalize(event.description
            .replaceAll(RegExp(r'\\n'), ' ')
            .split('(Export')[0]
            .replaceAll(RegExp(r'\s\s+'), ' ')
            .replaceAll('\\', ' ')
            .replaceAll('_', ' ')
            .trim());

        events.add(event);
        lastProp = ENDVEVENT;
      } else if (line.startsWith(DTSTART)) {
        event.dateStart = _getDateValue(line);
        lastProp = DTSTART;
      } else if (line.startsWith(DTEND)) {
        event.dateEnd = _getDateValue(line);
        lastProp = DTEND;
      } else if (line.startsWith(SUMMARY)) {
        event.title = capitalize(_getValue(line)).trim();
        lastProp = SUMMARY;
      } else if (line.startsWith(LOCATION)) {
        event.location = capitalize(
            _getValue(line).replaceAll('\\', ' ').replaceAll('_', ' ').trim());
        lastProp = LOCATION;
      } else if (line.startsWith(UID)) {
        event.uid = _getValue(line).trim();
        lastProp = UID;
      } else if (line.startsWith(DESCRIPTION) || lastProp == DESCRIPTION) {
        if (lastProp == DESCRIPTION)
          event.description += line.trim();
        else
          event.description += _getValue(line).trim();
        lastProp = DESCRIPTION;
      }
    });

    return events;
  }

  static String _getValue(String line) {
    // Gets the first index where a space occours
    final index = line.indexOf(":");
    return line.substring(index + 1); // Gets the value part
  }

  static DateTime _getDateValue(String line) {
    final d = DateTime.parse(_getValue(line).toString().substring(0, 15));
    final dUTC = Instant.utc(d.year, d.month, d.day, d.hour, d.minute);
    return dUTC.inZone(DateTimeZone.local).toDateTimeLocal();
  }
}
