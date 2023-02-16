import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:univagenda/models/analytics.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/preferences/theme.provider.dart';

class AnalyticsProvider {
  static void sendUserPrefsGroup(SettingsProvider prefs) {
    // User group prefs
    prefs.urlIcs.forEach((url) {
      final host = Uri.tryParse(url)?.host;
      if (host?.isNotEmpty ?? false) {
        FirebaseAnalytics.instance.logEvent(
          name: AnalyticsEvent.userDataSource,
          parameters: {AnalyticsValue.university: host!},
        );
      }
    });
  }

  static void sendUserPrefsDisplay(SettingsProvider prefs) {
    // User display prefs
    FirebaseAnalytics.instance.logEvent(
      name: AnalyticsEvent.userPrefsDisplay,
      parameters: <String, String>{
        AnalyticsValue.numberWeeks: prefs.numberWeeks.toString(),
        AnalyticsValue.displayAllDays: prefs.isDisplayAllDays.toString(),
        AnalyticsValue.horizontalView: prefs.calendarType.toString(),
      },
    );
  }

  static void sendUserPrefsColor(ThemeProvider theme) {
    // User display prefs
    FirebaseAnalytics.instance.logEvent(
      name: AnalyticsEvent.userPrefsColors,
      parameters: <String, String>{
        AnalyticsValue.themeMode: theme.themeMode.name,
        AnalyticsValue.primaryColor: theme.primaryColor.toString(),
        AnalyticsValue.accentColor: theme.accentColor.toString(),
        AnalyticsValue.noteColor: theme.noteColor.toString(),
      },
    );
  }

  static void sendForceRefresh(String value) {
    FirebaseAnalytics.instance.logEvent(
      name: AnalyticsEvent.refresh,
      parameters: <String, String>{value: AnalyticsAction.refresh},
    );
  }

  static void sendDrawerEvent(bool open) {
    String action = open ? AnalyticsAction.open : AnalyticsAction.close;
    FirebaseAnalytics.instance.logEvent(
      name: AnalyticsEvent.drawer,
      parameters: <String, bool>{action: true},
    );
  }

  static void sendLinkClicked(String value) {
    FirebaseAnalytics.instance.logEvent(
      name: AnalyticsEvent.link,
      parameters: <String, String>{value: AnalyticsAction.click},
    );
  }

  static void setScreen(dynamic object) {
    String className = object.runtimeType.toString();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: className,
      screenClassOverride: className,
    );
  }
}
