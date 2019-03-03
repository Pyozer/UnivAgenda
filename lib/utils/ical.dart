import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:timezone/standalone.dart';

const String BEGINVEVENT = "BEGIN:VEVENT";
const String ENDVEVENT = "END:VEVENT";
const String DTSTART = "DTSTART:";
const String DTEND = "DTEND:";
const String SUMMARY = "SUMMARY:";
const String DESCRIPTION = "DESCRIPTION:";
const String LOCATION = "LOCATION:";
const String UID = "UID:";
const String SEQUENCE = "SEQUENCE:";
const String STATUS = "STATUS:";
const String TRANSP = "TRANSP:";
const String RRULE = "RRULE:";
const String DTSTAMP = "DTSTAMP:";
const String CATEGORIES = "CATEGORIES:";
const String GEO = "GEO:";
const String URL = "URL:";
const String CLASS = "CLASS:";
const String LASTMODIFIED = "LAST-MODIFIED:";
const String CREATED = "CREATED:";
const String APPLE = "X-APPLE-STRUCTURED-LOCATION;";

const allTags = [
  BEGINVEVENT,
  ENDVEVENT,
  DTSTART,
  DTEND,
  SUMMARY,
  DESCRIPTION,
  LOCATION,
  UID,
  SEQUENCE,
  STATUS,
  TRANSP,
  RRULE,
  DTSTAMP,
  CATEGORIES,
  GEO,
  URL,
  CLASS,
  LASTMODIFIED,
  CREATED,
  APPLE,
];

class Ical {
  final String ical;
  String _lastTag;

  Ical(this.ical);

  bool isValidIcal() {
    if (ical != null && ical.trimLeft().startsWith("BEGIN:VCALENDAR")) if (ical
        .trimRight()
        .endsWith("END:VCALENDAR")) return true;
    return false;
  }

  Future<List<Course>> parseToIcal() async {
    if (ical == null || ical.trim().length == 0) return [];

    if (!isValidIcal()) throw ("Wrong ICS file format !");

    List<String> lines = ical.split("\n");
    List<Course> events = [];
    Course event;

    lines.forEach((line) {
      line = line.trim();
      if (isTag(line, BEGINVEVENT)) {
        event = Course.empty();
      } else if (isTag(line, ENDVEVENT)) {
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
      } else if (isTag(line, DTSTART)) {
        event?.dateStart = _getDateValue(line);
      } else if (isTag(line, DTEND)) {
        event?.dateEnd = _getDateValue(line);
      } else if (isTag(line, SUMMARY)) {
        event?.title = capitalize(_getValue(line)).trim();
      } else if (isTag(line, LOCATION)) {
        event?.location = capitalize(
          _getValue(line).replaceAll('\\', ' ').replaceAll('_', ' ').trim(),
        );
      } else if (isTag(line, UID)) {
        event?.uid = _getValue(line).trim();
      } else if (isTag(line, DESCRIPTION)) {
        event?.description ??= "";
        event?.description += _getValue(line).trim();
      }
    });

    return events;
  }

  bool isTag(String line, String tag) {
    bool isTag = false;
    if (line.startsWith(tag)) {
      isTag = true;
    } else {
      bool isOtherTag = allTags.indexWhere((t) => line.startsWith(t)) > -1;
      if (_lastTag == tag && !isOtherTag) isTag = true;
    }
    if (isTag) _lastTag = tag;
    return isTag;
  }

  String _getValue(String line) {
    // Gets the first index where a space occours
    final index = line.indexOf(":");
    if (index < 0) return line;
    return line.substring(index + 1).trim(); // Gets the value part
  }

  DateTime _getDateValue(String line) {
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
