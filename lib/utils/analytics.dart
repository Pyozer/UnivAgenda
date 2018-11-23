import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/models/analytics.dart';
import 'package:myagenda/utils/preferences.dart';

class AnalyticsProvider extends InheritedWidget {
  AnalyticsProvider(this.analytics, this.observer, {Key key, this.child})
      : super(key: key, child: child);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final Widget child;

  static AnalyticsProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(AnalyticsProvider)
        as AnalyticsProvider);
  }

  void sendUserPrefsGroup(PreferencesProviderState prefs) {
    // User group prefs
    analytics.logEvent(name: AnalyticsEvent.userPrefsGroup, parameters: {
      AnalyticsValue.groupKeys:
          prefs.urlIcs != null ? "Ical File" : prefs.groupKeys?.join(',') ?? "",
      AnalyticsValue.university:
          prefs.urlIcs ?? prefs.university?.name ?? "Unknown",
    });
  }

  void sendUserPrefsDisplay(PreferencesProviderState prefs) {
    // User display prefs
    analytics.logEvent(
      name: AnalyticsEvent.userPrefsDisplay,
      parameters: <String, String>{
        AnalyticsValue.numberWeeks: prefs.numberWeeks.toString(),
        AnalyticsValue.displayAllDays: prefs.isDisplayAllDays.toString(),
        AnalyticsValue.horizontalView: prefs.isHorizontalView.toString(),
      },
    );
  }

  void sendUserPrefsColor(PreferencesProviderState prefs) {
    // User display prefs
    analytics.logEvent(
      name: AnalyticsEvent.userPrefsColors,
      parameters: <String, String>{
        AnalyticsValue.darkTheme: prefs.theme.darkTheme.toString(),
        AnalyticsValue.primaryColor: Color(prefs.theme.primaryColor).toString(),
        AnalyticsValue.accentColor: Color(prefs.theme.accentColor).toString(),
        AnalyticsValue.noteColor: Color(prefs.theme.noteColor).toString(),
      },
    );
  }

  void sendForceRefresh(String value) {
    analytics.logEvent(
      name: AnalyticsEvent.refresh,
      parameters: <String, String>{value: AnalyticsAction.refresh},
    );
  }

  void sendDrawerEvent(bool open) {
    String action = open ? AnalyticsAction.open : AnalyticsAction.close;
    analytics.logEvent(
      name: AnalyticsEvent.drawer,
      parameters: <String, bool>{action: true},
    );
  }

  void sendLinkClicked(String value) {
    analytics.logEvent(
      name: AnalyticsEvent.link,
      parameters: <String, String>{value: AnalyticsAction.click},
    );
  }

  @override
  bool updateShouldNotify(AnalyticsProvider oldWidget) {
    return false;
  }
}
