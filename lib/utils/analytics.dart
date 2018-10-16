import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/models/analytics.dart';

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

  void sendUserPrefsGroup(var prefs) {
    // User group prefs
    analytics.logEvent(
      name: AnalyticsEvent.userPrefsGroup,
      parameters: <String, String>{
        AnalyticsValue.groupKeys: prefs.groupKeys.toString(),
      },
    );
  }

  void sendUserPrefsDisplay(var prefs) {
    // User display prefs
    analytics.logEvent(
      name: AnalyticsEvent.userPrefsDisplay,
      parameters: <String, dynamic>{
        AnalyticsValue.numberWeeks: prefs.numberWeeks,
        AnalyticsValue.displayAllDays: prefs.isDisplayAllDays,
        AnalyticsValue.headerGroup: prefs.isHeaderGroupVisible,
        AnalyticsValue.horizontalView: prefs.isHorizontalView,
      },
    );
  }

  void sendUserPrefsColor(var prefs) {
    // User display prefs
    analytics.logEvent(
      name: AnalyticsEvent.userPrefsColors,
      parameters: <String, dynamic>{
        AnalyticsValue.darkTheme: prefs.theme.darkTheme,
        AnalyticsValue.primaryColor: prefs.theme.primaryColor,
        AnalyticsValue.accentColor: prefs.theme.accentColor,
        AnalyticsValue.noteColor: prefs.theme.noteColor,
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

  void sendAdClicked(String value) {
    analytics.logEvent(
        name: AnalyticsEvent.ad,
        parameters: <String, String>{value: AnalyticsAction.click});
  }

  void sendAdOpen(String value) {
    analytics.logEvent(
        name: AnalyticsEvent.ad,
        parameters: <String, String>{value: AnalyticsAction.open});
  }

  @override
  bool updateShouldNotify(AnalyticsProvider oldWidget) {
    return false;
  }
}
