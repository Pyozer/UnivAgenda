class StringKey {

  static const APP_NAME = const StringKey._('app_name');

  static const DRAWER = const StringKey._('drawer');

  static const FINDROOM = const StringKey._('findroom');

  static const SETTINGS = const StringKey._('settings');
  static const SETTINGS_GENERAL = const StringKey._('settings_general');
  static const SETTINGS_DISPLAY = const StringKey._('settings_display');

  static const CAMPUS = const StringKey._('campus');
  static const SELECT_CAMPUS = const StringKey._('select_campus');
  static const DEPARTMENT = const StringKey._('department');
  static const SELECT_DEPARTMENT = const StringKey._('select_department');
  static const YEAR = const StringKey._('year');
  static const SELECT_YEAR = const StringKey._('select_year');
  static const GROUP = const StringKey._('group');
  static const SELECT_GROUP = const StringKey._('select_group');

  static const NUMBER_WEEK = const StringKey._('number_week');

  static const DARK_THEME = const StringKey._('dark_theme');
  static const DARK_THEME_DESC = const StringKey._('dark_theme_desc');
  static const PRIMARY_COLOR = const StringKey._('primary_color');
  static const PRIMARY_COLOR_DESC = const StringKey._('primary_color_desc');
  static const ACCENT_COLOR = const StringKey._('accent_color');
  static const ACCENT_COLOR_DESC = const StringKey._('accent_color_desc');
  static const NOTE_COLOR = const StringKey._('note_color');
  static const NOTE_COLOR_DESC = const StringKey._('note_color_desc');

  static const UPDATE = const StringKey._('update');
  static const ABOUT = const StringKey._('about');
  static const INTRO = const StringKey._('introduction');
  static const LOGOUT = const StringKey._('logout');

  static const ADD_EVENT = const StringKey._('add_event');

  static const CANCEL = const StringKey._('cancel');
  static const SAVE = const StringKey._('save');
  static const SUBMIT = const StringKey._('submit');

  static const WHAT_IS_IT = const StringKey._('what_is_it');
  static const ABOUT_WHAT = const StringKey._('about_what');

  static const AUTHOR = const StringKey._('author');
  static const DEVELOPER = const StringKey._('developer');
  static const SOCIAL = const StringKey._('social');
  static const GITHUB_PROJECT = const StringKey._('github_project');
  static const OTHER = const StringKey._('other');

  static const CHANGELOG = const StringKey._('changelog');
  static const CHANGELOG_DESC = const StringKey._('changelog_desc');
  static const OPENSOURCE_LICENCES = const StringKey._('opensource_licences');
  static const OPENSOURCE_LICENCES_DESC = const StringKey._('opensource_licences_desc');
  static const VERSION = const StringKey._('version');

  static const MADE_WITH = const StringKey._('made_with');

  static const SKIP = const StringKey._('skip');
  static const NEXT = const StringKey._('next');
  static const DONE = const StringKey._('done');

  static const INTRO_WELCOME_TITLE = const StringKey._('intro_welcome_title');
  static const INTRO_WELCOME_DESC = const StringKey._('intro_welcome_desc');

  static const INTRO_AGENDA_TITLE = const StringKey._('intro_agenda_title');
  static const INTRO_AGENDA_DESC = const StringKey._('intro_agenda_desc');

  static const INTRO_CUSTOM_TITLE = const StringKey._('intro_customization_title');
  static const INTRO_CUSTOM_DESC = const StringKey._('intro_customization_desc');

  static const INTRO_NOTE_TITLE = const StringKey._('intro_note_title');
  static const INTRO_NOTE_DESC = const StringKey._('intro_note_desc');

  static const INTRO_EVENT_TITLE = const StringKey._('intro_event_title');
  static const INTRO_EVENT_DESC = const StringKey._('intro_event_desc');

  static const INTRO_OFFLINE_TITLE = const StringKey._('intro_offline_title');
  static const INTRO_OFFLINE_DESC = const StringKey._('intro_offline_desc');

  static const COURSE_TEST = const StringKey._('course_test');
  static const COURSE_DETAILS = const StringKey._('course_details');

  static const NOTES = const StringKey._('notes');
  static const ADD_NOTE = const StringKey._('add_note');
  static const ADD_NOTE_PLACEHOLDER = const StringKey._('add_note_placeholder');
  static const ADD_NOTE_EMPTY = const StringKey._('add_note_empty');
  static const ADD_NOTE_SUBMIT = const StringKey._('add_note_submit');

  static const ADD_NOTE_BTN = const StringKey._('add_note_btn');
  static const DELETE = const StringKey._('delete');

  static const EVENT_COLOR = const StringKey._('event_color');
  static const EVENT_COLOR_DESC = const StringKey._('event_color_desc');

  static const TITLE_EVENT = const StringKey._('title_event');
  static const DESC_EVENT = const StringKey._('desc_event');
  static const LOCATION_EVENT = const StringKey._('location_event');
  static const DATE_EVENT = const StringKey._('date_event');

  static const START_TIME_EVENT = const StringKey._('start_time_event');
  static const END_TIME_EVENT = const StringKey._('end_time_event');

  static const REQUIRE_FIELD = const StringKey._('require_field');

  static const ERROR_END_TIME = const StringKey._('error_end_time');
  static const ERROR_END_TIME_TEXT = const StringKey._('error_end_time_text');

  static const OK = const StringKey._('ok');
  static const SEARCH = const StringKey._('search');

  static const FINDROOM_FROM = const StringKey._('findroom_from');
  static const FINDROOM_TO = const StringKey._('findroom_to');
  static const FINDROOM_AVAILABLE = const StringKey._('findroom_available');
  static const FINDROOM_NORESULT = const StringKey._('findroom_noresult');
  static const FINDROOM_NORESULT_TEXT = const StringKey._('findroom_noresult_text');

  static const LOGIN_USERNAME = const StringKey._('login_username');
  static const LOGIN_PASSWORD = const StringKey._('login_password');
  static const LOGIN_SUBMIT = const StringKey._('login_submit');
  static const LOGIN_SERVER_ERROR = const StringKey._('login_server_error');

  final String value;

  const StringKey._(this.value);
}