class AnalyticsEvent {
  static const String userDataSource = 'user_data_source';
  static const String userPrefsDisplay = 'user_display';
  static const String userPrefsColors = 'user_colors';

  static const String drawer = 'drawer';
  static const String refresh = 'refresh';

  static const String link = 'link';
}

class AnalyticsValue {
  // Prefs groups
  static const String university = 'university';
  // Prefs display
  static const String numberWeeks = 'number_weeks';
  static const String displayAllDays = 'display_all_day';
  static const String headerGroup = 'header_group';
  static const String horizontalView = 'horizontal_view';
  // Prefs colors
  static const String themeMode = 'theme_mode';
  static const String primaryColor = 'primary_color';
  static const String accentColor = 'accent_color';
  static const String noteColor = 'note_color';
  // URL Links
  static const String unidays = 'unidays_link';
  static const String lydia = 'lydia_link';
  static const String websiteJC = 'website_jc_link';
  static const String websiteJustin = 'website_justin_link';
  static const String twitter = 'twitter_link';
  static const String github = 'github_link';
  static const String store = 'store_link';
  // Refresh
  static const String refreshResources = 'refresh_resources';
  static const String refreshCourses = 'refresh_courses';
}

class AnalyticsAction {
  static const String open = 'open';
  static const String close = 'close';
  static const String refresh = 'refresh';
  static const String click = 'click';
}
