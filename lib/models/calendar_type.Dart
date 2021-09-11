import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

CalendarView? calendarTypeFromStr(String? calendarType) {
  for (CalendarView element in CalendarView.values) {
    if (element.toString() == calendarType) {
      return element;
    }
  }
  return null;
}

IconData getCalendarTypeIcon(CalendarView calendarType) {
  if (calendarType == CalendarView.day) {
    return Icons.view_week_outlined;
  } else if (calendarType == CalendarView.week) {
    return Icons.grid_on_outlined;
  } else if (calendarType == CalendarView.month) {
    return Icons.view_carousel_outlined;
  }
  return Icons.view_day_outlined;
}

CalendarView nextCalendarType(CalendarView current) {
  if (current == CalendarView.day) {
    return CalendarView.schedule;
  }
  if (current == CalendarView.schedule) {
    return CalendarView.week;
  }
  if (current == CalendarView.week) {
    return CalendarView.month;
  }
  return CalendarView.day;
}
