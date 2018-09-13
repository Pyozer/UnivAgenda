import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

class AnalyticsProvider extends InheritedWidget {
  AnalyticsProvider(this.analytics, this.observer, {Key key, this.child}) : super(key: key, child: child);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final Widget child;

  static AnalyticsProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(AnalyticsProvider)as AnalyticsProvider);
  }

  @override
  bool updateShouldNotify(AnalyticsProvider oldWidget) {
    return false;
  }
}