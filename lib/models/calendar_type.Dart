import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

enum CalendarType { HORIZONTAL, VERTICAL, MONTH_VIEW, WEEK_VIEW }

CalendarType calendarTypeFromStr(String calendarType) {
  for (CalendarType element in CalendarType.values) {
    if (element.toString() == calendarType) {
      return element;
    }
  }
  return null;
}

IconData getCalendarTypeIcon(CalendarType calendarType) {
  if (calendarType == CalendarType.VERTICAL)
    return OMIcons.viewWeek;
  else if (calendarType == CalendarType.WEEK_VIEW)
    return OMIcons.gridOn;
  else if (calendarType == CalendarType.MONTH_VIEW) return OMIcons.viewCarousel;
  return OMIcons.viewDay;
}

CalendarType nextCalendarType(CalendarType current) {
  if (current == CalendarType.HORIZONTAL)
    return CalendarType.VERTICAL;
  else if (current == CalendarType.VERTICAL)
    return CalendarType.WEEK_VIEW;
  else if (current == CalendarType.WEEK_VIEW) return CalendarType.MONTH_VIEW;
  return CalendarType.HORIZONTAL;
}
