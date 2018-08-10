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
  static const APPBAR_COLOR = const StringKey._('appbar_color');
  static const APPBAR_COLOR_DESC = const StringKey._('appbar_color_desc');
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
  static const OTHER = const StringKey._('other');

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

  final String value;

  const StringKey._(this.value);
}