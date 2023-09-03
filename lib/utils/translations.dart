import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:intl/intl_standalone.dart';

///
/// Preferences related
///
const List<String> _supportedLanguages = ['en', 'fr'];
const String kDefaultLang = 'en';

class GlobalTranslations {
  Locale? _locale;
  Map<String, dynamic>? _localizedValues;
  VoidCallback? _onLocaleChangedCallback;

  ///
  /// Returns the list of supported Locales
  ///
  Iterable<Locale> supportedLocales() {
    return _supportedLanguages.map((lang) => Locale(lang));
  }

  ///
  /// Returns if language is supported
  ///
  bool isSupported(Locale? locale) =>
      _supportedLanguages.contains(locale?.languageCode ?? '');

  ///
  /// Returns the translation that corresponds to the [key]
  ///
  String text(String key, [Map<String, dynamic>? params]) {
    // Return the requested string
    String text = (_localizedValues == null || _localizedValues![key] == null)
        ? '** $key not found'
        : _localizedValues![key];

    if (params != null && params.isNotEmpty) {
      for (String paramKey in params.keys) {
        text = text.replaceAll(
          RegExp('{$paramKey}'),
          params[paramKey].toString(),
        );
      }
    }
    return text;
  }

  ///
  /// Returns the current language code
  ///
  String get currentLanguage => _locale?.languageCode ?? kDefaultLang;

  ///
  /// Returns the current Locale
  ///
  Locale get locale => _locale ?? const Locale(kDefaultLang);

  ///
  /// One-time initialization
  ///
  Future<void> init() async {
    String? systemLocale = await findSystemLocale();

    if (systemLocale.isEmpty) systemLocale = kDefaultLang;
    Locale newLocal = Locale(systemLocale.split('_')[0]);
    if (_locale == null || _locale != newLocal) await setNewLanguage(newLocal);
    return;
  }

  ///
  /// Routine to change the language
  ///
  Future<void> setNewLanguage(Locale? locale) async {
    // Set the locale
    _locale = Locale(isSupported(locale) ? locale!.languageCode : kDefaultLang);

    // Load the language strings
    String jsonContent = await rootBundle.loadString(
      'res/locales/${_locale!.languageCode}.json',
    );
    _localizedValues = json.decode(jsonContent);

    // If there is a callback to invoke to notify that a language has changed
    if (_onLocaleChangedCallback != null) _onLocaleChangedCallback!();

    return;
  }

  ///
  /// Callback to be invoked when the user changes the language
  ///
  set onLocaleChangedCallback(VoidCallback callback) {
    _onLocaleChangedCallback = callback;
  }

  ///
  /// Singleton Factory
  ///
  static final _translations = GlobalTranslations._internal();
  factory GlobalTranslations() => _translations;

  GlobalTranslations._internal();
}

GlobalTranslations i18n = GlobalTranslations();
