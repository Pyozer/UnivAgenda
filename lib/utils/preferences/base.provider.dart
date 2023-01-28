import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseProvider extends ChangeNotifier {
  SharedPreferences? sharedPrefs;

  Future<void> initFromDisk();

  @protected
  void updatePref(VoidCallback f, [bool state = false]) {
    f();
    if (state) notifyListeners();
  }

  @protected
  void setString(String prefKey, String? value) {
    if (value == null) {
      sharedPrefs?.remove(prefKey);
    } else {
      sharedPrefs?.setString(prefKey, value);
    }
  }

  @protected
  void setStringList(String prefKey, List<String>? value) {
    if (value == null) {
      sharedPrefs?.remove(prefKey);
    } else {
      sharedPrefs?.setStringList(prefKey, value);
    }
  }

  @protected
  void setInt(String prefKey, int? value) {
    if (value == null) {
      sharedPrefs?.remove(prefKey);
    } else {
      sharedPrefs?.setInt(prefKey, value);
    }
  }

  @protected
  void setBool(String prefKey, bool? value) {
    if (value == null) {
      sharedPrefs?.remove(prefKey);
    } else {
      sharedPrefs?.setBool(prefKey, value);
    }
  }

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}
