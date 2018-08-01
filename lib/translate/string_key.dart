class StringKey {

  static const APP_NAME = const StringKey._('app_name');

  static const DRAWER = const StringKey._('drawer');

  static const ADD_EVENT = const StringKey._('add_event');

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

  static const UPDATE = const StringKey._('update');
  static const ABOUT = const StringKey._('about');
  static const INTRO = const StringKey._('introduction');
  static const LOGOUT = const StringKey._('logout');

  final String value;

  const StringKey._(this.value);
}