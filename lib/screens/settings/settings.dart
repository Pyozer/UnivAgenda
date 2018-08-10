import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/widgets/list_divider.dart';
import 'package:myagenda/widgets/list_tile_choices.dart';
import 'package:myagenda/widgets/list_tile_color.dart';
import 'package:myagenda/widgets/list_tile_input.dart';
import 'package:myagenda/widgets/list_tile_title.dart';
import 'package:myagenda/widgets/setting_card.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map _dataPrefs = {};

  @override
  void initState() {
    super.initState();
    _fetchSettingsValues();
  }

  Future _fetchSettingsValues() async {
    Map dataPrefs = await Preferences.getAllValues();
    setState(() {
      _dataPrefs = dataPrefs;
    });
  }

  void _editLocalPrefValue(String pref, dynamic newValue, {fState = true}) {
    if (fState)
      setState(() {
        _dataPrefs[pref] = newValue;
      });
    else
      _dataPrefs[pref] = newValue;
  }

  void _updatePrefGroup(String pref, String newValue) async {
    // Update dataPrefs value with new value selected
    _editLocalPrefValue(pref, newValue, fState: false);

    // Check and edit values if necessary (ex: Change campus, so change department etc..)
    // Values will be save by method changeGroupPref()
    Preferences
        .changeGroupPref(
            campus: _dataPrefs[PrefKey.CAMPUS],
            department: _dataPrefs[PrefKey.DEPARTMENT],
            year: _dataPrefs[PrefKey.YEAR],
            group: _dataPrefs[PrefKey.GROUP])
        .then((prefCalendar) {
      prefCalendar.getValues().forEach((key, value) {
        _editLocalPrefValue(key, value);
      });
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
              selectedValue: _dataPrefs[PrefKey.CAMPUS],
              values: Data.getAllCampus(),
              onChange: (value) => _updatePrefGroup(PrefKey.CAMPUS, value)),
          const ListDivider(),
          ListTileChoices(
              title: translations.get(StringKey.DEPARTMENT),
              titleDialog: translations.get(StringKey.SELECT_DEPARTMENT),
              selectedValue: _dataPrefs[PrefKey.DEPARTMENT],
              values: Data.getCampusDepartments(_dataPrefs[PrefKey.CAMPUS]),
              onChange: (value) => _updatePrefGroup(PrefKey.DEPARTMENT, value)),
          const ListDivider(),
          ListTileChoices(
            title: translations.get(StringKey.YEAR),
            titleDialog: translations.get(StringKey.SELECT_YEAR),
            selectedValue: _dataPrefs[PrefKey.YEAR],
            values: Data.getYears(
                _dataPrefs[PrefKey.CAMPUS], _dataPrefs[PrefKey.DEPARTMENT]),
            onChange: (value) => _updatePrefGroup(PrefKey.YEAR, value),
          ),
          const ListDivider(),
          ListTileChoices(
              title: translations.get(StringKey.GROUP),
              titleDialog: translations.get(StringKey.SELECT_GROUP),
              selectedValue: _dataPrefs[PrefKey.GROUP],
              values: Data.getGroups(_dataPrefs[PrefKey.CAMPUS],
                  _dataPrefs[PrefKey.DEPARTMENT], _dataPrefs[PrefKey.YEAR]),
              onChange: (value) => _updatePrefGroup(PrefKey.GROUP, value))
        ]);
  }

  void _handleNumberWeek(String numberWeek) {
    Preferences.setNumberWeekStr(numberWeek).then((value) {
      _editLocalPrefValue(PrefKey.NUMBER_WEEK, value);
    });
  }

  void _handleDarkTheme(bool isDark) {
    Preferences.setDarkTheme(isDark).then((value) {
      _editLocalPrefValue(PrefKey.DARK_THEME, value);
      DynamicTheme.of(context).changeTheme(brightness: getBrightness(value));
    });
  }

  void _handleAppbarColor(Color newColor) {
    Preferences.setAppbarColor(newColor.value).then((value) {
      _editLocalPrefValue(PrefKey.APPBAR_COLOR, value);
      DynamicTheme.of(context).changeTheme(primaryColor: newColor);
    });
  }

  void _handleNoteColor(Color newColor) {
    Preferences.setNoteColor(newColor.value).then((value) {
      _editLocalPrefValue(PrefKey.NOTE_COLOR, value);
    });
  }

  Widget _buildSettingsDisplay() {
    final translate = Translations.of(context);
    return SettingCard(
        header: translate.get(StringKey.SETTINGS_DISPLAY),
        children: [
          ListTileInput(
              title: translate.get(StringKey.NUMBER_WEEK),
              defaultValue: _dataPrefs[PrefKey.NUMBER_WEEK]?.toString() ??
                  PrefKey.DEFAULT_NUMBER_WEEK.toString(),
              inputType:
                  TextInputType.numberWithOptions(decimal: false, signed: true),
              onChange: _handleNumberWeek),
          const ListDivider(),
          SwitchListTile(
              title: ListTileTitle(translate.get(StringKey.DARK_THEME)),
              subtitle: Text(translate.get(StringKey.DARK_THEME_DESC)),
              value:
                  _dataPrefs[PrefKey.DARK_THEME] ?? PrefKey.DEFAULT_DARK_THEME,
              activeColor: Theme.of(context).accentColor,
              onChanged: _handleDarkTheme),
          const ListDivider(),
          ListTileColor(
              title: translate.get(StringKey.APPBAR_COLOR),
              description: translate.get(StringKey.APPBAR_COLOR_DESC),
              defaultValue: _dataPrefs[PrefKey.APPBAR_COLOR] != null
                  ? Color(_dataPrefs[PrefKey.APPBAR_COLOR])
                  : const Color(PrefKey.DEFAULT_APPBAR_COLOR),
              onChange: _handleAppbarColor),
          const ListDivider(),
          ListTileColor(
              title: translate.get(StringKey.NOTE_COLOR),
              description: translate.get(StringKey.NOTE_COLOR_DESC),
              defaultValue: _dataPrefs[PrefKey.NOTE_COLOR] != null
                  ? Color(_dataPrefs[PrefKey.NOTE_COLOR])
                  : const Color(PrefKey.DEFAULT_NOTE_COLOR),
              onChange: _handleNoteColor)
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
        title: Translations.of(context).get(StringKey.SETTINGS),
        body: ListView(
          children: [_buildSettingsGeneral(), _buildSettingsDisplay()],
        ));
  }
}
