class PrefKey {
  static get campus => 'campus';
  static get department => 'department';
  static get year => 'year';
  static get group => 'group';
  static get numberWeek => 'number_week';
  static get appbarColor => 'appbar_color';
  static get noteColor => 'note_color';
  static get darkTheme => 'isDark';

  static const defaultNumberWeek = 5;
  static const defaultAppbarColor = 0xFFFF0000;
  static const defaultNoteColor = 0xFFFFFF00;
  static const defaultDarkTheme = false;

  static get firstBoot => "first_boot";

  static get cachedIcal => "cached_ical";
}
