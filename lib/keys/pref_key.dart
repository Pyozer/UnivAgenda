import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/courses/course.dart';
import '../models/courses/custom_course.dart';
import '../models/courses/note.dart';
import '../models/courses/hidden.dart';

class PrefKey {
  static const urlIcs = 'list_url_ics';

  static const numberWeeks = 'number_weeks';
  static const isPreviousCourses = 'is_previous_courses';

  static const primaryColor = 'primary_color';
  static const accentColor = 'accent_color';
  static const noteColor = 'note_color';
  static const themeMode = 'theme_mode';

  static const appLaunchCounter = 'app_launch_counter';
  static const isIntroDone = 'is_intro_done';
  static const isDisplayAllDays = 'is_display_all_days';
  static const isGenerateEventColor = 'is_generate_event_color';
  static const isFullHiddenEvents = 'is_full_hidden_event';

  static const calendarType = 'calendar_type';
  static const resourcesDate = 'ressources_date_cache';
  static const cachedIcalDate = 'ical_date_cache';

  static const notes = 'notes';
  static const customEvent = 'custom_events';
  static const hiddenEvent = 'list_hidden_events';
  static const renamedEvent = 'renamed_events';

  static const defaultNumberWeeks = 8;
  static const defaultIsPreviousCourses = true;
  static const defaultMaximumPrevDays = 365;
  static const defaultPrimaryColor = Colors.red;
  static const defaultAccentColor = Colors.redAccent;
  static const defaultNoteColor = Colors.redAccent;

  static const defaultThemeMode = ThemeMode.system;
  static const defaultAppLaunchCounter = 0;
  static const defaultIntroDone = false;
  static const defaultDisplayAllDays = false;
  static const defaultGenerateEventColor = false;
  static const defaultFullHiddenEvent = false;
  static const defaultCalendarType = CalendarView.timelineDay;

  static const List<String> defaultUrlIcs = [];
  static List<Course> defaultCachedCourses = [];
  static List<Note> defaultNotes = [];
  static List<CustomCourse> defaultCustomEvents = [];
  static List<Hidden> defaultHiddenEvents = [];
  static Map<String, String> defaultRenamedEvent = {};

  static const String cachedCoursesFile = 'cached_courses.ics';
}
