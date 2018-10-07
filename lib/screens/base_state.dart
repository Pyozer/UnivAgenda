import 'package:flutter/material.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  PreferencesProviderState prefs;
  Translations translations;
  ThemeData theme;
  AnalyticsProvider analyticsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    prefs = PreferencesProvider.of(context);
    translations = Translations.of(context);
    theme = Theme.of(context);
    analyticsProvider = AnalyticsProvider.of(context);
  }

}