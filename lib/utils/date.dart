import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  static DateTime changeTime(DateTime dt, int hour, int minute, [int second = 0]) {
    return DateTime(dt.year, dt.month, dt.day, hour, minute, second);
  }

  static String dateFromNow(DateTime date, [Locale locale]) {
    if (locale == null) locale = kDefaultLocal;

    DateTime dateTimeToday = DateTime.now();

    final lang = locale.languageCode == "fr"
        ? ["Aujourd'hui", "Demain"]
        : ["Today", "Tomorrow"];

    if (dateTimeToday.day == date.day &&
        dateTimeToday.month == date.month &&
        dateTimeToday.year == date.year)
      return lang[0];
    else if ((dateTimeToday.day + 1) == date.day &&
        dateTimeToday.month == date.month &&
        dateTimeToday.year == date.year) return lang[1];

    final dateFormat = (dateTimeToday.year == date.year)
        ? DateFormat.MMMMEEEEd(locale.languageCode)
        : DateFormat.yMMMMEEEEd(locale.languageCode);

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
}
