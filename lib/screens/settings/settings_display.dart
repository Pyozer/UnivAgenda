import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/widgets/list_tile_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDisplayScreen extends StatefulWidget {
  @override
  _SettingsDisplayScreenState createState() =>
      new _SettingsDisplayScreenState();
}

class _SettingsDisplayScreenState extends State<SettingsDisplayScreen> {

  Map dataPrefs = {};

  @override
  void initState() {
    super.initState();
    _fetchSettingsValues();
  }

  Future _fetchSettingsValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _updateLocalPrefValue('campus', prefs.getString('campus'));
    _updateLocalPrefValue('departments', prefs.getString('departments'));
    _updateLocalPrefValue('year', prefs.getString('year'));
    _updateLocalPrefValue('group', prefs.getString('group'));
  }

  void _updateLocalPrefValue(String pref, String newValue) {
    setState(() {
      dataPrefs[pref] = newValue;
    });
  }

  Future _updateGlobalPrefValue(String pref, String newValue) async {
    _updateLocalPrefValue(pref, newValue);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(pref, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      title: Translations.of(context).get(Translate.SETTINGS_DISPLAY),
      body: Column(
        children: [
          ListTileChoices(
            title: "Campus",
            selectedValue: dataPrefs['campus'],
            values: Data.getAllCampus(),
            onChange: (value) => _updateGlobalPrefValue('campus', value)
          ),
          ListTileChoices(
            title: "Département",
            selectedValue: dataPrefs['departments'],
            values: Data.getCampusDepartments(dataPrefs['campus']),
            onChange: (value) => _updateGlobalPrefValue('departments', value)
          ),
          ListTileChoices(
            title: "Année",
            selectedValue: dataPrefs['year'],
            values: Data.getYears(dataPrefs['campus'], dataPrefs['departments']),
            onChange: (value) => _updateGlobalPrefValue('year', value),
          ),
          ListTileChoices(
            title: "Groupe",
            selectedValue: dataPrefs['group'],
            values: Data.getGroups(dataPrefs['campus'], dataPrefs['departments'], dataPrefs['year']),
            onChange: (value) => _updateGlobalPrefValue('group', value)
          )
        ]
      )
    );
  }
}
