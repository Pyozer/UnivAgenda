import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/utils/date.dart';
import 'package:univagenda/utils/functions.dart';

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
      return Course(
        uid: vevent['uid'],
        dateStart: DateTime.parse(vevent["dtstart"]['dt']).toLocal(),
        dateEnd: DateTime.parse(vevent["dtend"]['dt']).toLocal(),
        description: capitalize(
          vevent['description']
                  ?.replaceAll('\n', ' ')
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
