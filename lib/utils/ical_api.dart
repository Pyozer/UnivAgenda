import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:timezone/standalone.dart';

import '../models/courses/course.dart';
import 'date.dart';
import 'functions.dart';

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

  static Future<List<Course>> icalToCourses(ICalendar? ical) async {
    if (ical?.data.isEmpty ?? true) {
      return [];
    }

    return ical!.data.where((e) => e['type'] == 'VEVENT').map((vevent) {
      final start = vevent['dtstart'] as IcsDateTime;
      final end = vevent['dtend'] as IcsDateTime;

      final dtstart = start.tzid?.isNotEmpty ?? false
          ? TZDateTime.from(
              DateTime.parse(start.dt),
              getLocation(start.tzid!),
            )
          : DateTime.parse(start.dt);

      final dtend = end.tzid?.isNotEmpty ?? false
          ? TZDateTime.from(
              DateTime.parse(end.dt),
              getLocation(end.tzid!),
            )
          : DateTime.parse(end.dt);

      return Course(
        uid: vevent['uid'],
        dateStart: dtstart.toLocal(),
        dateEnd: dtend.toLocal(),
        description: capitalize(
          vevent['description']
                  ?.replaceAll('\\n', ' ')
                  .split('(Export')[0]
                  .replaceAll(RegExp(r'\s\s+'), ' ')
                  .replaceAll('\\', ' ')
                  .replaceAll('_', ' ')
                  .trim() ??
              '',
        ),
        location: capitalize(
          vevent['location']
                  ?.replaceAll('\\', ' ')
                  .replaceAll('_', ' ')
                  .trim() ??
              '',
        ),
        title: vevent['summary'] ?? '',
      );
    }).toList();
  }
}
