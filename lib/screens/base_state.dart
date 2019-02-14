import 'package:flutter/material.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/preferences.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  PreferencesProviderState prefs;
  ThemeData theme;
  AnalyticsProvider analyticsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    prefs = PreferencesProvider.of(context);
    theme = Theme.of(context);
    analyticsProvider = AnalyticsProvider.of(context);
  }
}
