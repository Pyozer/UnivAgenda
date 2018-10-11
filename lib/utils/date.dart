import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myagenda/models/simple_duration.dart';
import 'package:myagenda/utils/functions.dart';

class Date {
  static const kDefaultLocal = Locale('en');

  static bool notSameDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  static TimeOfDay addTimeToTime(TimeOfDay time, [hours = 0, minutes = 0]) {
    return TimeOfDay(
      hour: (time.hour + hours) % 24,
      minute: (time.minute + minutes) % 24,
    );
  }

  static DateTime dateFromDateTime(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  static DateTime setTimeFromOther(DateTime date, DateTime time) {
    return changeTime(date, time.hour, time.minute, time.second);
  }

  static DateTime changeTime(DateTime dt, int hour, int minute,
      [int second = 0]) {
    return DateTime(dt.year, dt.month, dt.day, hour, minute, second);
  }

  static String dateFromNow(DateTime date,
      [Locale locale, bool shortDate = false]) {
    if (locale == null) locale = kDefaultLocal;

    DateTime dateTimeToday = DateTime.now();

    final lang = locale.languageCode == "fr"
        ? ["Aujourd'hui", "Demain"]
        : ["Today", "Tomorrow"];

    if (!notSameDay(dateTimeToday, date))
      return lang[0];
    else if ((dateTimeToday.day + 1) == date.day &&
        dateTimeToday.month == date.month &&
        dateTimeToday.year == date.year) return lang[1];

    DateFormat dateFormat;

    if (dateTimeToday.year == date.year) {
      if (shortDate)
        dateFormat = DateFormat.MMMEd(locale.languageCode);
      else
        dateFormat = DateFormat.MMMMEEEEd(locale.languageCode);
    } else {
      if (shortDate)
        dateFormat = DateFormat.yMMMEd(locale.languageCode);
      else
        dateFormat = DateFormat.yMMMMEEEEd(locale.languageCode);
    }

    return capitalize(dateFormat.format(date));
  }

  static String extractTime(DateTime date, [Locale locale]) {
    if (date == null) return "";
    if (locale == null) locale = kDefaultLocal;

    return DateFormat.Hm(locale.languageCode).format(date);
  }

  static String extractDate(DateTime date, [Locale locale]) {
    if (date == null) return "";
    if (locale == null) locale = kDefaultLocal;

    return DateFormat.yMMMMd(locale.languageCode).format(date);
  }

  static String extractTimeWithDate(DateTime dateTime, [Locale locale]) {
    if (dateTime == null) return "";

    return DateFormat.jm(locale.languageCode).format(dateTime) +
        ' (' +
        DateFormat.MMMEd(locale.languageCode).format(dateTime) +
        ')';
  }

  static int dateToInt(DateTime dt) {
    int year = dt.year;
    String month = "${dt.month}";
    if (month.length == 1) month = "0" + month;

    String day = "${dt.day}";
    if (day.length == 1) day = "0" + day;

    return int.parse("$year$month$day");
  }

  static DateTime intToDate(int dateInt) {
    String dateValue = dateInt.toString();

    int year = int.parse(dateValue.substring(0, 4));
    int month = int.parse(dateValue.substring(4, 6));
    int day = int.parse(dateValue.substring(6, 8));

    return DateTime(year, month, day);
  }

  static int calcDaysToEndDate(DateTime startDate, int numberWeeks) {
    return (numberWeeks == 0) ? 0 : DateTime.daysPerWeek * numberWeeks;
  }

  static SimpleDuration calculateDuration(DateTime startDate, DateTime endDate) {
    var diff = endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch; 

    var hours   = (diff / 3.6e6).floor();
    var minutes = ((diff % 3.6e6) / 6e4).floor();

    return SimpleDuration(hours, minutes);
  }
}
