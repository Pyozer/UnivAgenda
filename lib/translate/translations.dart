import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Translate {

  static const APP_NAME = const Translate._('app_name');

  static const DRAWER = const Translate._('drawer');

  static const ADD_EVENT = const Translate._('add_event');

  static const FINDROOM = const Translate._('findroom');

  static const SETTINGS = const Translate._('settings');
  static const SETTINGS_GENERAL = const Translate._('settings_general');
  static const SETTINGS_DISPLAY = const Translate._('settings_display');

  static const CAMPUS = const Translate._('campus');
  static const SELECT_CAMPUS = const Translate._('select_campus');
  static const DEPARTMENT = const Translate._('department');
  static const SELECT_DEPARTMENT = const Translate._('select_department');
  static const YEAR = const Translate._('year');
  static const SELECT_YEAR = const Translate._('select_year');
  static const GROUP = const Translate._('group');
  static const SELECT_GROUP = const Translate._('select_group');

  static const UPDATE = const Translate._('update');
  static const ABOUT = const Translate._('about');
  static const INTRO = const Translate._('introduction');
  static const LOGOUT = const Translate._('logout');

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

  String get(Translate key) {
    return _localizedValues[key.value] ?? '#${key.value} not found#';
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
