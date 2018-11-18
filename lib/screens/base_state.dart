import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/preferences.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  PreferencesProviderState prefs;
  ThemeData theme;
  AnalyticsProvider analyticsProvider;

  String translation(String key, [Map<String, String> params]) =>
      FlutterI18n.translate(context, key, params);

  String translationPlural(String key, int count) =>
      FlutterI18n.plural(context, "$key.times", count);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    prefs = PreferencesProvider.of(context);
    theme = Theme.of(context);
    analyticsProvider = AnalyticsProvider.of(context);
  }
}
