import 'package:intl/intl.dart';

class IcalAPI {
  static String prepareURL(String baseUrl, int resID, int numberWeeks) {
    final date = DateTime.now();

    final numDays = (numberWeeks == 0) ? 0 : 7 * numberWeeks + 7 - date.weekday;
    final durationToAdd = Duration(days: numDays);

    final dateFormat = DateFormat("yyyy-MM-dd");
    final startDate = dateFormat.format(date);
    final endDate = dateFormat.format(date.add(durationToAdd));
    
    baseUrl = baseUrl.replaceAll("%res%", resID.toString());
    baseUrl = baseUrl.replaceAll("%startDate%", startDate);
    baseUrl = baseUrl.replaceAll("%lastDate%", endDate);

    return baseUrl;
  }
}
