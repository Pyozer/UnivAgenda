import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Translate {

  static const APP_NAME = const Translate._('app_name');

  static const DRAWER = const Translate._('drawer');

  static const FINDROOM = const Translate._('findroom');
  static const SETTINGS = const Translate._('settings');
  static const UPDATE = const Translate._('update');
  static const ABOUT = const Translate._('about');
  static const INTRO = const Translate._('intro');
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

  String text(Translate key) {
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
