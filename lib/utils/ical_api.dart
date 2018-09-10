import 'package:intl/intl.dart';

class IcalAPI {
  static String prepareURL(int resID, int numberWeeks) {
    final date = DateTime.now();

    final numDays = (numberWeeks == 0) ? 0 : 7 * numberWeeks + 7 - date.weekday;
    final durationToAdd = Duration(days: numDays);

    final dateFormat = DateFormat("yyyy-MM-dd");
    final startDate = dateFormat.format(date);
    final endDate = dateFormat.format(date.add(durationToAdd));

    String base =
        'http://edt.univ-lemans.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?projectId=1&calType=ical';
    base += '&resources=' + resID.toString();
    base += '&firstDate=' + startDate + '&lastDate=' + endDate;

    return base;
  }
}
