import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/settings/list_tile_choices.dart';
import 'package:myagenda/widgets/settings/list_tile_color.dart';
import 'package:myagenda/widgets/settings/list_tile_input.dart';
import 'package:myagenda/widgets/settings/list_tile_title.dart';
import 'package:myagenda/widgets/ui/list_divider.dart';
import 'package:myagenda/widgets/ui/setting_card.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _dataPrefs = {};
  Translations translations;

  @override
  void initState() {
    super.initState();
    _fetchSettingsValues();
  }

  void _fetchSettingsValues() async {
    Map<String, dynamic> dataPrefs = await Preferences.getAllValues();
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
    Preferences.changeGroupPref(
            campus: _dataPrefs[PrefKey.campus],
            department: _dataPrefs[PrefKey.department],
            year: _dataPrefs[PrefKey.year],
            group: _dataPrefs[PrefKey.group])
        .then((prefCalendar) {
      prefCalendar.getValues().forEach((key, value) {
        _editLocalPrefValue(key, value);
      });
    });
  }

  Widget _buildSettingsGeneral() {
    var campus = _dataPrefs[PrefKey.campus];
    var department = _dataPrefs[PrefKey.department];
    var year = _dataPrefs[PrefKey.year];
    var group = _dataPrefs[PrefKey.group];

    return SettingCard(
      header: translations.get(StringKey.SETTINGS_GENERAL),
      children: [
        ListTileChoices(
          title: translations.get(StringKey.CAMPUS),
          titleDialog: translations.get(StringKey.SELECT_CAMPUS),
          selectedValue: campus,
          values: Data.getAllCampus(),
          onChange: (value) => _updatePrefGroup(PrefKey.campus, value),
        ),
        const ListDivider(),
        ListTileChoices(
          title: translations.get(StringKey.DEPARTMENT),
          titleDialog: translations.get(StringKey.SELECT_DEPARTMENT),
          selectedValue: department,
          values: Data.getCampusDepartments(campus),
          onChange: (value) => _updatePrefGroup(PrefKey.department, value),
        ),
        const ListDivider(),
        ListTileChoices(
          title: translations.get(StringKey.YEAR),
          titleDialog: translations.get(StringKey.SELECT_YEAR),
          selectedValue: year,
          values: Data.getYears(campus, department),
          onChange: (value) => _updatePrefGroup(PrefKey.year, value),
        ),
        const ListDivider(),
        ListTileChoices(
          title: translations.get(StringKey.GROUP),
          titleDialog: translations.get(StringKey.SELECT_GROUP),
          selectedValue: group,
          values: Data.getGroups(campus, department, year),
          onChange: (value) => _updatePrefGroup(PrefKey.group, value),
        )
      ],
    );
  }

  void _handleNumberWeek(String numberWeek) {
    Preferences.setNumberWeekStr(numberWeek).then((value) {
      _editLocalPrefValue(PrefKey.numberWeek, value);
    });
  }

  void _handleHorizontalView(bool isHorizontal) {
    Preferences.setHorizontalView(isHorizontal).then((value) {
      _editLocalPrefValue(PrefKey.isHorizontalView, value);
    });
  }

  void _handleDarkTheme(bool isDark) {
    Preferences.setDarkTheme(isDark).then((value) {
      _editLocalPrefValue(PrefKey.darkTheme, value);
      DynamicTheme.of(context).changeTheme(brightness: getBrightness(value));
    });
  }

  void _handlePrimaryColor(Color newColor) {
    Preferences.setPrimaryColor(newColor.value).then((value) {
      _editLocalPrefValue(PrefKey.primaryColor, value);
      DynamicTheme.of(context).changeTheme(primaryColor: newColor);
    });
  }

  void _handleAccentColor(Color newColor) {
    Preferences.setAccentColor(newColor.value).then((value) {
      _editLocalPrefValue(PrefKey.accentColor, value);
      DynamicTheme.of(context).changeTheme(accentColor: newColor);
    });
  }

  void _handleNoteColor(Color newColor) {
    Preferences.setNoteColor(newColor.value).then((value) {
      _editLocalPrefValue(PrefKey.noteColor, value);
    });
  }

  Widget _buildSettingsDisplay() {
    final numberWeeks = _dataPrefs[PrefKey.numberWeek].toString();
    final isHorizontal = _dataPrefs[PrefKey.isHorizontalView];
    final isDarkTheme = _dataPrefs[PrefKey.darkTheme];
    final primaryColorValue = _dataPrefs[PrefKey.primaryColor];
    final accentColorValue = _dataPrefs[PrefKey.accentColor];
    final noteColorValue = _dataPrefs[PrefKey.noteColor];

    return SettingCard(
        header: translations.get(StringKey.SETTINGS_DISPLAY),
        children: [
          ListTileInput(
              title: translations.get(StringKey.NUMBER_WEEK),
              defaultValue: numberWeeks,
              inputType:
                  TextInputType.numberWithOptions(decimal: false, signed: true),
              onChange: _handleNumberWeek),
          const ListDivider(),
          SwitchListTile(
              title: ListTileTitle(translations.get(StringKey.HORIZONTAL_VIEW)),
              subtitle: Text(translations.get(StringKey.HORIZONTAL_VIEW_DESC)),
              value: isHorizontal,
              activeColor: Theme.of(context).accentColor,
              onChanged: _handleHorizontalView),
          SwitchListTile(
              title: ListTileTitle(translations.get(StringKey.DARK_THEME)),
              subtitle: Text(translations.get(StringKey.DARK_THEME_DESC)),
              value: isDarkTheme,
              activeColor: Theme.of(context).accentColor,
              onChanged: _handleDarkTheme),
          const ListDivider(),
          ListTileColor(
              title: translations.get(StringKey.PRIMARY_COLOR),
              description: translations.get(StringKey.PRIMARY_COLOR_DESC),
              selectedColor: Color(primaryColorValue),
              onColorChange: _handlePrimaryColor),
          const ListDivider(),
          ListTileColor(
              title: translations.get(StringKey.ACCENT_COLOR),
              description: translations.get(StringKey.ACCENT_COLOR_DESC),
              selectedColor: Color(accentColorValue),
              onColorChange: _handleAccentColor,
              colors: [
                Colors.redAccent,
                Colors.pinkAccent,
                Colors.purpleAccent,
                Colors.deepPurpleAccent,
                Colors.indigoAccent,
                Colors.blueAccent,
                Colors.lightBlueAccent,
                Colors.cyanAccent,
                Colors.tealAccent,
                Colors.greenAccent,
                Colors.lightGreenAccent,
                Colors.limeAccent,
                Colors.yellowAccent,
                Colors.amberAccent,
                Colors.orangeAccent,
                Colors.deepOrangeAccent,
                Colors.brown,
                Colors.grey,
                Colors.blueGrey
              ]),
          const ListDivider(),
          ListTileColor(
              title: translations.get(StringKey.NOTE_COLOR),
              description: translations.get(StringKey.NOTE_COLOR_DESC),
              selectedColor: Color(noteColorValue),
              onColorChange: _handleNoteColor)
        ]);
  }

  @override
  Widget build(BuildContext context) {
    translations = Translations.of(context);

    return AppbarPage(
      title: translations.get(StringKey.SETTINGS),
      body: _dataPrefs.length > 0
          ? ListView(
              children: [_buildSettingsGeneral(), _buildSettingsDisplay()],
            )
          : Container(),
    );
  }
}
