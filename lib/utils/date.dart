class Date {

  static bool notSameDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  static String dateFromNow(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);

    String month;
    switch (tm.month) {
      case DateTime.january:
        month = "January";
        break;
      case DateTime.february:
        month = "February";
        break;
      case DateTime.march:
        month = "March";
        break;
      case DateTime.april:
        month = "April";
        break;
      case DateTime.may:
        month = "May";
        break;
      case DateTime.june:
        month = "June";
        break;
      case DateTime.july:
        month = "July";
        break;
      case DateTime.august:
        month = "August";
        break;
      case DateTime.september:
        month = "September";
        break;
      case DateTime.october:
        month = "October";
        break;
      case DateTime.november:
        month = "November";
        break;
      case DateTime.december:
        month = "December";
        break;
    }

    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1)
      return "Today";
    else if (difference.compareTo(twoDay) < 1)
      return "Yesterday";
    else if (difference.compareTo(oneWeek) < 1) {
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
    } else if (tm.year == today.year)
      return '${tm.day} $month';
    else
      return '${tm.day} $month ${tm.year}';
    return "";
  }
}
