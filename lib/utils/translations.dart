import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:myagenda/keys/string_key.dart';

class Translations {
  Translations(Locale locale) {
    this.locale = locale;
    _localizedValues = null;
  }

  Locale locale;
  static Map<String, dynamic> _localizedValues;

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }

  String getPlural(StringKey key, int number, [List replacements]) {
    if (number > 1 && _localizedValues.containsKey(key.value + "_PLURAL"))
      return _getTranslation(key.value + "_PLURAL", replacements);
    else
      return _getTranslation(key.value, replacements);
  }

  String get(StringKey key, [List replacements]) {
    return _getTranslation(key.value, replacements);
  }

  String _getTranslation(String key, [List replacements]) {
    String stringValue = _localizedValues[key] ?? '#$key not found#';
    replacements?.forEach((value) {
      stringValue = stringValue.replaceFirst(new RegExp("%s%"), value);
    });

    return stringValue;
  }

  static Future<Translations> load(Locale locale) async {
    Translations translations = new Translations(locale);
    String jsonContent =
        await rootBundle.loadString("res/locales/${locale.languageCode}.json");
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
