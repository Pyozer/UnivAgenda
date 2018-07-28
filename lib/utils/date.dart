import 'dart:ui';

import 'package:intl/intl.dart';

class Date {
  static bool notSameDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  static String dateFromNow(DateTime date, [Locale locale]) {
    if (locale == null) locale = Locale('en');

    DateTime today = new DateTime.now();

    int differenceDays = date.difference(today).inDays;

    if (differenceDays == 0)
      return "Today";
    else if (differenceDays == 1) return "Tomorrow";

    String format = 'EEEE dd MMMM';
    if(today.year != date.year)
      format += ' yyyy';

    var formatter = new DateFormat(format, locale.languageCode);
    return formatter.format(date);

    /*String month;
    if (date.month == DateTime.january)
      month = "January";
    else if (date.month == DateTime.february)
      month = "February";
    else if (date.month == DateTime.march)
      month = "March";
    else if (date.month == DateTime.april)
      month = "April";
    else if (date.month == DateTime.may)
      month = "May";
    else if (date.month == DateTime.june)
      month = "June";
    else if (date.month == DateTime.july)
      month = "July";
    else if (date.month == DateTime.august)
      month = "August";
    else if (date.month == DateTime.september)
      month = "September";
    else if (date.month == DateTime.october)
      month = "October";
    else if (date.month == DateTime.november)
      month = "November";
    else if (date.month == DateTime.december) month = "December";

    if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case DateTime.monday:
          return "Monday";
        case DateTime.tuesday:
          return "Tuesday";
        case DateTime.wednesday:
          return "Wednesday";
        case DateTime.thursday:
          return "Thurdsday";
        case DateTime.friday:
          return "Friday";
        case DateTime.saturday:
          return "Saturday";
        case DateTime.sunday:
          return "Sunday";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
    return "";*/
  }
}
