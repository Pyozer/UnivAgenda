import 'dart:ui';

import 'package:intl/intl.dart';

class Date {
  static bool notSameDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  static String dateFromNow(DateTime date, [Locale locale]) {
    if (locale == null) locale = Locale('en');

    DateTime today = DateTime.now();

    int differenceDays = date.difference(today).inDays;

    if (differenceDays == 0)
      return "Today";
    else if (differenceDays == 1) return "Tomorrow";

    String format = 'EEEE dd MMMM';
    if (today.year != date.year) format += ' yyyy';

    final formatter = DateFormat(format, locale.languageCode);
    return formatter.format(date);
  }
}
