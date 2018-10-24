import 'package:flutter/services.dart';
import 'package:myagenda/models/ical_model.dart';
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

  static Future<List<IcalModel>> parseToIcal(String icalData) async {
    if (icalData == null || icalData.trim().length == 0) return [];

    if (!isValidIcal(icalData)) throw ("Wrong ICS file format !");

    await TimeMachine.initialize({'rootBundle': rootBundle});

    List<String> lines = icalData.split("\n");
    List<IcalModel> events = [];
    IcalModel event;

    String lastProp;

    lines.forEach((line) {
      if (line.startsWith(BEGINVEVENT)) {
        event = IcalModel();
        lastProp = BEGINVEVENT;
      } else if (line.startsWith(ENDVEVENT)) {
        // Remove exported indicator of description
        event.description = event.description
            .replaceAll(RegExp(r'\\n'), ' ')
            .split('(Export')[0]
            .replaceAll(RegExp(r'\s\s+'), ' ')
            .trim();

        events.add(event);
        lastProp = ENDVEVENT;
      } else if (line.startsWith(DTSTART)) {
        event.dtstart = _getDateValue(line);
        lastProp = DTSTART;
      } else if (line.startsWith(DTEND)) {
        event.dtend = _getDateValue(line);
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
        if (lastProp == DESCRIPTION)
          event.description += line.trim();
        else
          event.description += _getValue(line).trim();
        lastProp = DESCRIPTION;
      }
    });

    return events;
  }

  static _getValue(String line) {
    // Gets the first index where a space occours
    final index = line.indexOf(":");
    return line.substring(index + 1); // Gets the value part
  }

  static DateTime _getDateValue(String line) {
    final d = DateTime.parse(_getValue(line).toString().substring(0, 15));
    final dUTC = Instant.utc(d.year, d.month, d.day, d.hour, d.minute);
    return dUTC.toDateTimeLocal();
  }
}
