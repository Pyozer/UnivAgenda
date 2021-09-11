import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:univagenda/models/analytics.dart';
import 'package:univagenda/utils/preferences.dart';

class AnalyticsProvider {
  static final FirebaseAnalytics analytics = FirebaseAnalytics();

  static void sendUserPrefsGroup(PrefsProvider prefs) {
    // User group prefs
    analytics.logEvent(name: AnalyticsEvent.userPrefsGroup, parameters: {
      AnalyticsValue.groupKeys: "Ical File",
      AnalyticsValue.university: prefs.urlIcs,
    });
  }

  static void sendUserPrefsDisplay(PrefsProvider prefs) {
    // User display prefs
    analytics.logEvent(
      name: AnalyticsEvent.userPrefsDisplay,
      parameters: <String, String>{
        AnalyticsValue.numberWeeks: prefs.numberWeeks.toString(),
        AnalyticsValue.displayAllDays: prefs.isDisplayAllDays.toString(),
        AnalyticsValue.horizontalView: prefs.calendarType.toString(),
      },
    );
  }

  static void sendUserPrefsColor(PrefsProvider prefs) {
    // User display prefs
    analytics.logEvent(
      name: AnalyticsEvent.userPrefsColors,
      parameters: <String, String>{
        AnalyticsValue.darkTheme: prefs.theme.darkTheme.toString(),
        AnalyticsValue.primaryColor: prefs.theme.primaryColor.toString(),
        AnalyticsValue.accentColor: prefs.theme.accentColor.toString(),
        AnalyticsValue.noteColor: prefs.theme.noteColor.toString(),
      },
    );
  }

  static void sendForceRefresh(String value) {
    analytics.logEvent(
      name: AnalyticsEvent.refresh,
      parameters: <String, String>{value: AnalyticsAction.refresh},
    );
  }

  static void sendDrawerEvent(bool open) {
    String action = open ? AnalyticsAction.open : AnalyticsAction.close;
    analytics.logEvent(
      name: AnalyticsEvent.drawer,
      parameters: <String, bool>{action: true},
    );
  }

  static void sendLinkClicked(String value) {
    analytics.logEvent(
      name: AnalyticsEvent.link,
      parameters: <String, String>{value: AnalyticsAction.click},
    );
  }

  static void setScreen(dynamic object) {
    String className = object.runtimeType.toString();
    analytics.setCurrentScreen(
      screenName: className,
      screenClassOverride: className,
    );
  }
}
