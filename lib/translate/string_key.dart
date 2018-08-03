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
  static const SELECT_NUMBER_WEEK = const StringKey._('select_number_week');

  static const DARK_THEME = const StringKey._('dark_theme');
  static const DARK_THEME_DESC = const StringKey._('dark_theme_desc');
  static const APPBAR_COLOR = const StringKey._('appbar_color');
  static const APPBAR_COLOR_DESC = const StringKey._('appbar_color_desc');

  static const UPDATE = const StringKey._('update');
  static const ABOUT = const StringKey._('about');
  static const INTRO = const StringKey._('introduction');
  static const LOGOUT = const StringKey._('logout');

  static const ADD_EVENT = const StringKey._('add_event');

  static const CANCEL = const StringKey._('cancel');
  static const SAVE = const StringKey._('save');
  static const SUBMIT = const StringKey._('submit');

  final String value;

  const StringKey._(this.value);
}