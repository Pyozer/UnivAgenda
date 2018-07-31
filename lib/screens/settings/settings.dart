import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/models/PrefsCalendar.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/widgets/list_divider.dart';
import 'package:myagenda/widgets/list_tile_choices.dart';
import 'package:myagenda/widgets/setting_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map dataPrefs = {};

  final List<String> prefsKeys = ['campus', 'department', 'year', 'group'];

  @override
  void initState() {
    super.initState();
    _fetchSettingsValues();
  }

  Future _fetchSettingsValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefsKeys.forEach((key) {
      _updateLocalPrefValue(key, prefs.getString(key));
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

  void _updateGlobalPrefValue(String pref, String newValue) {
    // Update dataPrefs value with new value selected
    _updateLocalPrefValue(pref, newValue, fState: false);

    // Check and edit values if necessary (ex: Change campus, so change department etc..)
    PrefsCalendar values = Data.checkDataValues(
        campus: dataPrefs['campus'],
        department: dataPrefs['department'],
        year: dataPrefs['year'],
        group: dataPrefs['group']);

    // Reupdate dataPrefs with correct values
    values.getValues().forEach((key, value) {
      _updateLocalPrefValue(key, value);
    });

    // Save settings
    _savePrefs();
  }

  Future _savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefsKeys.forEach((key) {
      prefs.setString(key, dataPrefs[key]);
    });
  }

  Widget _buildSettingsGeneral() {
    final translations = Translations.of(context);
    return SettingCard(header: "Groupe", children: [
      ListTileChoices(
          title: translations.get(Translate.CAMPUS),
          titleDialog: translations.get(Translate.SELECT_CAMPUS),
          selectedValue: dataPrefs['campus'],
          values: Data.getAllCampus(),
          onChange: (value) => _updateGlobalPrefValue('campus', value)),
      const ListDivider(),
      ListTileChoices(
          title: translations.get(Translate.DEPARTMENT),
          titleDialog: translations.get(Translate.SELECT_DEPARTMENT),
          selectedValue: dataPrefs['department'],
          values: Data.getCampusDepartments(dataPrefs['campus']),
          onChange: (value) => _updateGlobalPrefValue('department', value)),
      const ListDivider(),
      ListTileChoices(
        title: translations.get(Translate.YEAR),
        titleDialog: translations.get(Translate.SELECT_YEAR),
        selectedValue: dataPrefs['year'],
        values: Data.getYears(dataPrefs['campus'], dataPrefs['department']),
        onChange: (value) => _updateGlobalPrefValue('year', value),
      ),
      const ListDivider(),
      ListTileChoices(
          title: translations.get(Translate.GROUP),
          titleDialog: translations.get(Translate.SELECT_GROUP),
          selectedValue: dataPrefs['group'],
          values: Data.getGroups(
              dataPrefs['campus'], dataPrefs['department'], dataPrefs['year']),
          onChange: (value) => _updateGlobalPrefValue('group', value))
    ]);
  }

  Widget _buildSettingsDisplay() {
    final translations = Translations.of(context);
    return SettingCard(header: "Groupe", children: [
      ListTileChoices(
          title: translations.get(Translate.CAMPUS),
          titleDialog: translations.get(Translate.SELECT_CAMPUS),
          selectedValue: dataPrefs['campus'],
          values: Data.getAllCampus(),
          onChange: (value) => _updateGlobalPrefValue('campus', value)),
      const ListDivider(),
      ListTileChoices(
          title: translations.get(Translate.DEPARTMENT),
          titleDialog: translations.get(Translate.SELECT_DEPARTMENT),
          selectedValue: dataPrefs['department'],
          values: Data.getCampusDepartments(dataPrefs['campus']),
          onChange: (value) => _updateGlobalPrefValue('department', value)),
      const ListDivider(),
      ListTileChoices(
        title: translations.get(Translate.YEAR),
        titleDialog: translations.get(Translate.SELECT_YEAR),
        selectedValue: dataPrefs['year'],
        values: Data.getYears(dataPrefs['campus'], dataPrefs['department']),
        onChange: (value) => _updateGlobalPrefValue('year', value),
      ),
      const ListDivider(),
      ListTileChoices(
          title: translations.get(Translate.GROUP),
          titleDialog: translations.get(Translate.SELECT_GROUP),
          selectedValue: dataPrefs['group'],
          values: Data.getGroups(
              dataPrefs['campus'], dataPrefs['department'], dataPrefs['year']),
          onChange: (value) => _updateGlobalPrefValue('group', value))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    return AppbarPage(
      title: translations.get(Translate.SETTINGS_DISPLAY),
      body: ListView(
        children: [
          _buildSettingsGeneral(),
          _buildSettingsDisplay()
        ],
      )
    );
  }
}
