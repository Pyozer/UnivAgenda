import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/models/PrefsCalendar.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/translate/string_key.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/widgets/list_divider.dart';
import 'package:myagenda/widgets/list_tile_choices.dart';
import 'package:myagenda/widgets/list_tile_input.dart';
import 'package:myagenda/widgets/setting_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefKey {
  static const CAMPUS = 'campus';
  static const DEPARTMENT = 'department';
  static const YEAR = 'year';
  static const GROUP = 'group';
  static const NUMBER_WEEK = 'number_week';
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map dataPrefs = {};

  final List<String> prefsKeys = [
    PrefKey.CAMPUS,
    PrefKey.DEPARTMENT,
    PrefKey.YEAR,
    PrefKey.GROUP,
    PrefKey.NUMBER_WEEK
  ];

  @override
  void initState() {
    super.initState();
    _fetchSettingsValues();
  }

  Future _fetchSettingsValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefsKeys.forEach((key) {
      _updateLocalPrefValue(key, prefs.getString(key) ?? '');
    });
  }

  void _updateLocalPrefValue(String pref, String newValue, {fState = true}) {
    if (fState)
      setState(() {
        dataPrefs[pref] = newValue;
      });
    else
      dataPrefs[pref] = newValue;
  }

  void _updateGlobalPrefGroupValue(String pref, String newValue) {
    // Update dataPrefs value with new value selected
    _updateLocalPrefValue(pref, newValue, fState: false);

    // Check and edit values if necessary (ex: Change campus, so change department etc..)
    PrefsCalendar values = Data.checkDataValues(
        campus: dataPrefs[PrefKey.CAMPUS],
        department: dataPrefs[PrefKey.DEPARTMENT],
        year: dataPrefs[PrefKey.YEAR],
        group: dataPrefs[PrefKey.GROUP]);

    // Reupdate dataPrefs with correct values
    values.getValues().forEach((key, value) {
      _updateLocalPrefValue(key, value);
    });

    // Save settings
    _savePrefs(
        [PrefKey.CAMPUS, PrefKey.DEPARTMENT, PrefKey.YEAR, PrefKey.GROUP]);
  }

  void _updateGlobalPrefValue(String pref, String newValue) {
    // Update dataPrefs value with new value selected
    _updateLocalPrefValue(pref, newValue, fState: false);
    // Save settings
    _savePrefs([pref]);
  }

  Future _savePrefs(List keys) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    keys.forEach((key) {
      prefs.setString(key, dataPrefs[key]);
    });
  }

  Widget _buildSettingsGeneral() {
    final translations = Translations.of(context);
    return SettingCard(
        header: translations.get(StringKey.SETTINGS_GENERAL),
        children: [
          ListTileChoices(
              title: translations.get(StringKey.CAMPUS),
              titleDialog: translations.get(StringKey.SELECT_CAMPUS),
              selectedValue: dataPrefs[PrefKey.CAMPUS],
              values: Data.getAllCampus(),
              onChange: (value) =>
                  _updateGlobalPrefGroupValue(PrefKey.CAMPUS, value)),
          const ListDivider(),
          ListTileChoices(
              title: translations.get(StringKey.DEPARTMENT),
              titleDialog: translations.get(StringKey.SELECT_DEPARTMENT),
              selectedValue: dataPrefs[PrefKey.DEPARTMENT],
              values: Data.getCampusDepartments(dataPrefs[PrefKey.CAMPUS]),
              onChange: (value) =>
                  _updateGlobalPrefGroupValue(PrefKey.DEPARTMENT, value)),
          const ListDivider(),
          ListTileChoices(
            title: translations.get(StringKey.YEAR),
            titleDialog: translations.get(StringKey.SELECT_YEAR),
            selectedValue: dataPrefs[PrefKey.YEAR],
            values: Data.getYears(
                dataPrefs[PrefKey.CAMPUS], dataPrefs[PrefKey.DEPARTMENT]),
            onChange: (value) =>
                _updateGlobalPrefGroupValue(PrefKey.YEAR, value),
          ),
          const ListDivider(),
          ListTileChoices(
              title: translations.get(StringKey.GROUP),
              titleDialog: translations.get(StringKey.SELECT_GROUP),
              selectedValue: dataPrefs[PrefKey.GROUP],
              values: Data.getGroups(dataPrefs[PrefKey.CAMPUS],
                  dataPrefs[PrefKey.DEPARTMENT], dataPrefs[PrefKey.YEAR]),
              onChange: (value) =>
                  _updateGlobalPrefGroupValue(PrefKey.GROUP, value))
        ]);
  }

  Widget _buildSettingsDisplay() {
    final translations = Translations.of(context);
    return SettingCard(
        header: translations.get(StringKey.SETTINGS_DISPLAY),
        children: [
          ListTileInput(
              title: translations.get(StringKey.NUMBER_WEEK),
              titleDialog: translations.get(StringKey.SELECT_NUMBER_WEEK),
              defaultValue: dataPrefs[PrefKey.NUMBER_WEEK],
              inputType:
                  TextInputType.numberWithOptions(decimal: false, signed: true),
              onChange: (value) {
                _updateGlobalPrefValue(PrefKey.NUMBER_WEEK, value);
              }),
          const ListDivider(),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    return AppbarPage(
        title: translations.get(StringKey.SETTINGS),
        body: ListView(
          children: [_buildSettingsGeneral(), _buildSettingsDisplay()],
        ));
  }
}
