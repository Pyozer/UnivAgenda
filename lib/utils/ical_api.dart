import 'package:intl/intl.dart';
import 'package:myagenda/data.dart';

class IcalAPI {
  static String prepareURL(String campus, String department, String year,
      String group, int numberWeeks) {
    final resID = Data.getGroupRes(campus, department, year, group).toString();

    final date = DateTime.now();

    final durationToAdd = Duration(days: 7 * numberWeeks + 7 - date.weekday);

    final dateFormat = DateFormat("yyyy-MM-dd");
    final startDate = dateFormat.format(date);
    final endDate = dateFormat.format(date.add(durationToAdd));

    String base =
        'http://edt.univ-lemans.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?projectId=1&calType=ical';
    base += '&resources=' + resID;
    base += '&firstDate=' + startDate + '&lastDate=' + endDate;

    return base;
  }
}
