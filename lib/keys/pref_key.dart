import 'package:myagenda/models/courses/custom_course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/models/preferences/university.dart';

class PrefKey {
  static const university = 'university';
  static const campus = 'campus';
  static const department = 'department';
  static const year = 'year';
  static const group = 'group';
  static const urlIcs = "url_ics";

  static const numberWeeks = 'number_weeks';

  static const primaryColor = 'primary_color';
  static const accentColor = 'accent_color';
  static const noteColor = 'note_color';
  static const isDarkTheme = 'is_dark_theme';

  static const installUID = 'install_uid';
  static const appLaunchCounter = 'app_launch_counter';
  static const isIntroDone = 'is_intro_done';
  static const isUserLogged = 'is_user_logged';
  static const isHorizontalView = 'is_horizontal_view';
  static const isDisplayAllDays = 'is_display_all_days';
  static const isHeaderGroup = 'is_header_group';
  static const isGenerateEventColor = 'is_generate_event_color';

  static const resourcesDate = 'ressources_date';

  static const notes = 'notes';
  static const customEvent = 'custom_events';

  static const defaultNumberWeeks = 4;
  static const defaultPrimaryColor = 0xFFF44336; // = Colors.red[500]
  static const defaultAccentColor = 0xFFFF5252;
  static const defaultNoteColor = 0xFFFF5252;

  static const defaultDarkTheme = false;
  static const defaultAppLaunchCounter = 0;
  static const defaultIntroDone = false;
  static const defaultUserLogged = false;
  static const defaultHorizontalView = false;
  static const defaultDisplayAllDays = false;
  static const defaultHeaderGroup = true;
  static const defaultGenerateEventColor = false;

  static const defaultUrlIcs = null;
  static const defaultCachedIcal = "";
  static const List<University> defaultListUniversity = [];
  static const String defaultListUniversityJson = "[]";
  static const Map<String, dynamic> defaultResources = {};
  static const String defaultResourcesJson = "{}";
  static const int defaultResourcesDate = 0;
  static const List<Note> defaultNotes = [];
  static const List<CustomCourse> defaultCustomEvents = [];

  static const String listUniversityFile = 'university.json';
  static const String resourcesFile = 'resources.json';
  static const String cachedIcalFile = 'cached_ical.ics';

}
