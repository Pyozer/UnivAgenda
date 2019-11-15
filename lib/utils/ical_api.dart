import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/models/ical/ical.dart';
import 'package:univagenda/utils/date.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:timezone/standalone.dart';

class IcalPrepareResult {
  final DateTime firstDate;
  final DateTime lastDate;

  IcalPrepareResult(this.firstDate, this.lastDate);
}

class IcalAPI {
  static IcalPrepareResult prepareIcalDates(int weeks, [int daysBefore = 0]) {
    final date = DateTime.now();

    final addDaysToEnd = Duration(days: Date.calcDaysToEndDate(date, weeks));
    final daysToSubstract = Duration(days: daysBefore);

    final startDate = date.subtract(daysToSubstract);
    final endDate = date.add(addDaysToEnd);

    return IcalPrepareResult(startDate, endDate);
  }

  static Future<List<Course>> icalToCourses(Ical ical) async {
    if (ical == null || ical.vevents.isEmpty) return [];

    return ical.vevents.map((vevent) {
      return Course(
        uid: vevent.uid,
        dateStart: _applyTimezone(vevent.dtstart),
        dateEnd: _applyTimezone(vevent.dtend),
        description: capitalize(
          vevent.description
              .replaceAll('\n', ' ')
              .split('(Export')[0]
              .replaceAll(RegExp(r'\s\s+'), ' ')
              .replaceAll('\\', ' ')
              .replaceAll('_', ' ')
              .trim(),
        ),
        location: capitalize(
          vevent.location.replaceAll('\\', ' ').replaceAll('_', ' ').trim(),
        ),
        title: vevent.summary,
      );
    }).toList();
  }

  static DateTime _applyTimezone(DateTime datetime) {
    final d = datetime.toUtc();
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
