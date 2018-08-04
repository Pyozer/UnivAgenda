import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/models/pref_key.dart';
import 'package:myagenda/models/prefs_calendar.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/translate/string_key.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/widgets/list_divider.dart';
import 'package:myagenda/widgets/list_tile_choices.dart';
import 'package:myagenda/widgets/list_tile_color.dart';
import 'package:myagenda/widgets/list_tile_input.dart';
import 'package:myagenda/widgets/list_tile_switch.dart';
import 'package:myagenda/widgets/setting_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map dataPrefs = {};

  @override
  void initState() {
    super.initState();
    _fetchSettingsValues();
  }

  Future _fetchSettingsValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _updateLocalPrefValue(PrefKey.CAMPUS, prefs.getString(PrefKey.CAMPUS));
    _updateLocalPrefValue(
        PrefKey.DEPARTMENT, prefs.getString(PrefKey.DEPARTMENT));
    _updateLocalPrefValue(PrefKey.YEAR, prefs.getString(PrefKey.YEAR));
    _updateLocalPrefValue(PrefKey.GROUP, prefs.getString(PrefKey.GROUP));
    _updateLocalPrefValue(
        PrefKey.NUMBER_WEEK, prefs.getString(PrefKey.NUMBER_WEEK));
    _updateLocalPrefValue(
        PrefKey.DARK_THEME, prefs.getBool(PrefKey.DARK_THEME));
    _updateLocalPrefValue(
        PrefKey.APPBAR_COLOR, prefs.getInt(PrefKey.APPBAR_COLOR));
  }

  void _updateLocalPrefValue(String pref, dynamic newValue, {fState = true}) {
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

  void _updateGlobalPrefValue(String pref, dynamic newValue) {
    // Update dataPrefs value with new value selected
    _updateLocalPrefValue(pref, newValue, fState: false);
    // Save settings
    _savePrefs([pref]);
  }

  Future _savePrefs(List keys) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    keys.forEach((key) {
      if (dataPrefs[key] is int)
        prefs.setInt(key, dataPrefs[key]);
      else if (dataPrefs[key] is double)
        prefs.setBool(key, dataPrefs[key]);
      else if (dataPrefs[key] is bool)
        prefs.setBool(key, dataPrefs[key]);
      else
        prefs.setString(key, dataPrefs[key].toString());
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
              onChange: (String value) {
                _updateGlobalPrefValue(PrefKey.NUMBER_WEEK, value);
              }),
          const ListDivider(),
          SwitchListTile(
            title: Text(translations.get(StringKey.DARK_THEME)),
            subtitle: Text(translations.get(StringKey.DARK_THEME_DESC)),
            value: dataPrefs[PrefKey.DARK_THEME] ?? false,
            onChanged: (bool value) {
              _updateGlobalPrefValue(PrefKey.DARK_THEME, value);
              DynamicTheme.of(context).changeTheme(
                  brightness: value ? Brightness.dark : Brightness.light);
            }
          ),
          /*ListTileSwitch(
              title: translations.get(StringKey.DARK_THEME),
              description: translations.get(StringKey.DARK_THEME_DESC),
              defaultValue: dataPrefs[PrefKey.DARK_THEME],
              onChange: (bool isDark) {
                _updateGlobalPrefValue(PrefKey.DARK_THEME, isDark);
                DynamicTheme.of(context).changeTheme(
                    brightness: isDark ? Brightness.dark : Brightness.light);
              }),*/
          const ListDivider(),
          ListTileColor(
              title: translations.get(StringKey.APPBAR_COLOR),
              description: translations.get(StringKey.APPBAR_COLOR_DESC),
              defaultValue: dataPrefs[PrefKey.APPBAR_COLOR] != null
                  ? Color(dataPrefs[PrefKey.APPBAR_COLOR])
                  : Colors.red,
              onChange: (Color newColor) {
                _updateGlobalPrefValue(PrefKey.APPBAR_COLOR, newColor.value);
                DynamicTheme.of(context).changeTheme(primaryColor: newColor);
              })
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
