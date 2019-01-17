import 'package:intl/intl.dart';
import 'package:myagenda/utils/date.dart';

class IcalAPI {
  static String prepareURL(String baseUrl, int resID, int numberWeeks) {
    final date = DateTime.now();

    final addDaysToEnd = Duration(days: Date.calcDaysToEndDate(date, numberWeeks));

    final dateFormat = DateFormat("yyyy-MM-dd", 'en');
    final startDate = dateFormat.format(date);
    final endDate = dateFormat.format(date.add(addDaysToEnd));
    
    baseUrl = baseUrl.replaceAll("%res%", resID.toString());
    baseUrl = baseUrl.replaceAll("%startDate%", startDate);
    baseUrl = baseUrl.replaceAll("%lastDate%", endDate);

    return baseUrl;
  }
}
