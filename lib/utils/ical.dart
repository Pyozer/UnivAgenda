import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:timezone/standalone.dart';

const String BEGINVEVENT = "BEGIN:VEVENT";
const String ENDVEVENT = "END:VEVENT";
const String DTSTART = "DTSTART";
const String DTEND = "DTEND";
const String SUMMARY = "SUMMARY";
const String DESCRIPTION = "DESCRIPTION";
const String LOCATION = "LOCATION";
const String UID = "UID";
// No used, just to stop description
const String SEQUENCE = "SEQUENCE";
const String STATUS = "STATUS";
const String TRANSP = "TRANSP";
const String RRULE = "RRULE";
const String DTSTAMP = "DTSTAMP";
const String CATEGORIES = "CATEGORIES";
const String GEO = "GEO";
const String URL = "URL";
const String CLASS = "CLASS";
const String LASTMODIFIED = "LAST-MODIFIED";
const String CREATED = "CREATED";

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

    lines.forEach((line) {
      if (line.startsWith(BEGINVEVENT)) {
        event = Course.empty();
      } else if (line.startsWith(ENDVEVENT)) {
        // Remove exported indicator of description
        event?.description = capitalize(
          event.description
              .replaceAll(RegExp(r'\\n'), ' ')
              .split('(Export')[0]
              .replaceAll(RegExp(r'\s\s+'), ' ')
              .replaceAll('\\', ' ')
              .replaceAll('_', ' ')
              .trim(),
        );
        events.add(event);
      } else if (line.startsWith(DTSTART)) {
        event?.dateStart = _getDateValue(line);
      } else if (line.startsWith(DTEND)) {
        event?.dateEnd = _getDateValue(line);
      } else if (line.startsWith(SUMMARY)) {
        event?.title = capitalize(_getValue(line)).trim();
      } else if (line.startsWith(LOCATION)) {
        event?.location = capitalize(
          _getValue(line).replaceAll('\\', ' ').replaceAll('_', ' ').trim(),
        );
      } else if (line.startsWith(UID)) {
        event?.uid = _getValue(line).trim();
      } else if (_isDescTag(line)) {
        event?.description ??= "";
        event?.description += _getValue(line).trim();
      }
    });

    return events;
  }

  static bool _isDescTag(String line) {
    if (line.startsWith(DESCRIPTION)) return true;
    return [
          SEQUENCE,
          STATUS,
          TRANSP,
          RRULE,
          DTSTAMP,
          CATEGORIES,
          GEO,
          URL,
          CLASS,
          CREATED,
          LASTMODIFIED,
        ].indexWhere((s) => line.startsWith(s)) <
        0;
  }

  static String _getValue(String line) {
    // Gets the first index where a space occours
    final index = line.indexOf(":");
    if (index < 0) return line;
    return line.substring(index + 1).trim(); // Gets the value part
  }

  static DateTime _getDateValue(String line) {
    final d = DateTime.parse(_getValue(line)).toUtc();
    return TZDateTime.utc(
      d.year,
      d.month,
      d.day,
      d.hour,
      d.minute,
      d.second,
    ).toLocal();
  }
}
