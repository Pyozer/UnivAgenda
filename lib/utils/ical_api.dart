import 'package:intl/intl.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/ical/ical.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:timezone/standalone.dart';

class IcalAPI {
  static String prepareIcalURL(String baseUrl, int resID, int weeks,
      [int daysBefore = 0]) {
    final date = DateTime.now();

    final addDaysToEnd = Duration(days: Date.calcDaysToEndDate(date, weeks));
    final daysToSubstract = Duration(days: daysBefore);

    final dateFormat = DateFormat("yyyy-MM-dd", 'en');
    final startDate = dateFormat.format(date.subtract(daysToSubstract));
    final endDate = dateFormat.format(date.add(addDaysToEnd));

    baseUrl = baseUrl.replaceAll("%res%", resID.toString());
    baseUrl = baseUrl.replaceAll("%startDate%", startDate);
    baseUrl = baseUrl.replaceAll("%lastDate%", endDate);

    return baseUrl;
  }

  static Future<List<Course>> icalToCourses(Ical ical) async {
    if (ical == null || ical.vcalendar.isEmpty) return [];

    return ical.vcalendar[0].vevent.map((vevent) {
      return Course(
        uid: vevent.uid,
        dateStart: _applyTimezone(vevent.dtstart),
        dateEnd: _applyTimezone(vevent.dtend),
        description: capitalize(
          vevent.description
              .replaceAll(RegExp(r'\\n'), ' ')
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
