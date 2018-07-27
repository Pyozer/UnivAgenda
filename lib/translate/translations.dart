import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Translate {

  static const APP_NAME = const Translate._('app_name');
  static const DRAWER_FINDROOM = const Translate._('drawer_findroom');
  static const DRAWER_SETTINGS = const Translate._('drawer_settings');
  static const DRAWER_UPDATE = const Translate._('drawer_update');
  static const DRAWER_ABOUT = const Translate._('drawer_about');
  static const DRAWER_INTRO = const Translate._('drawer_intro');
  static const DRAWER_LOGOUT = const Translate._('drawer_logout');

  final String value;

  const Translate._(this.value);
}

class Translations {
  Translations(Locale locale) {
    this.locale = locale;
    _localizedValues = null;
  }

  Locale locale;
  static Map<dynamic, dynamic> _localizedValues;

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }

  String text(Translate key) {
    return _localizedValues[key.value] ?? '** $key not found';
  }

  static Future<Translations> load(Locale locale) async {
    Translations translations = new Translations(locale);
    String jsonContent =
        await rootBundle.loadString("locales/${locale.languageCode}.json");
    _localizedValues = json.decode(jsonContent);
    return translations;
  }

  get currentLanguage => locale.languageCode;
}

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) => Translations.load(locale);

  @override
  bool shouldReload(TranslationsDelegate old) => false;
}
