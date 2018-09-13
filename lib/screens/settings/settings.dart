import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
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
  Translations translations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget _buildSettingsGeneral() {
    final prefs = PreferencesProvider.of(context);
    final calendar = prefs.calendar;

    return SettingCard(
      header: translations.get(StringKey.SETTINGS_GENERAL),
      children: [
        ListTileChoices(
          title: translations.get(StringKey.CAMPUS),
          titleDialog: translations.get(StringKey.SELECT_CAMPUS),
          selectedValue: calendar.campus,
          values: prefs.getAllCampus(calendar.university),
          onChange: (value) => prefs.setCampus(value),
        ),
        const ListDivider(),
        ListTileChoices(
          title: translations.get(StringKey.DEPARTMENT),
          titleDialog: translations.get(StringKey.SELECT_DEPARTMENT),
          selectedValue: calendar.department,
          values: prefs.getCampusDepartments(
            calendar.university,
            calendar.campus,
          ),
          onChange: (value) => prefs.setDepartment(value),
        ),
        const ListDivider(),
        ListTileChoices(
          title: translations.get(StringKey.YEAR),
          titleDialog: translations.get(StringKey.SELECT_YEAR),
          selectedValue: calendar.year,
          values: prefs.getYears(
            calendar.university,
            calendar.campus,
            calendar.department,
          ),
          onChange: (value) => prefs.setYear(value),
        ),
        const ListDivider(),
        ListTileChoices(
          title: translations.get(StringKey.GROUP),
          titleDialog: translations.get(StringKey.SELECT_GROUP),
          selectedValue: calendar.group,
          values: prefs.getGroups(
            calendar.university,
            calendar.campus,
            calendar.department,
            calendar.year,
          ),
          onChange: (value) => prefs.setGroup(value),
        )
      ],
    );
  }

  Widget _buildSettingsDisplay() {
    final prefs = PreferencesProvider.of(context);

    return SettingCard(
      header: translations.get(StringKey.SETTINGS_DISPLAY),
      children: [
        ListTileInput(
          title: translations.get(StringKey.NUMBER_WEEK),
          defaultValue: prefs.numberWeeks.toString(),
          inputType:
              TextInputType.numberWithOptions(decimal: false, signed: true),
          onChange: (value) {
            prefs.setNumberWeeks(isNumeric(value) ? int.parse(value) : -1);
          },
        ),
        SwitchListTile(
          title: ListTileTitle(translations.get(StringKey.DARK_THEME)),
          subtitle: Text(translations.get(StringKey.DARK_THEME_DESC)),
          value: prefs.theme.darkTheme,
          activeColor: Theme.of(context).accentColor,
          onChanged: (value) => prefs.setDarkTheme(value),
        ),
        const ListDivider(),
        ListTileColor(
          title: translations.get(StringKey.PRIMARY_COLOR),
          description: translations.get(StringKey.PRIMARY_COLOR_DESC),
          selectedColor: Color(prefs.theme.primaryColor),
          onColorChange: (color) => prefs.setPrimaryColor(color.value),
        ),
        const ListDivider(),
        ListTileColor(
          title: translations.get(StringKey.ACCENT_COLOR),
          description: translations.get(StringKey.ACCENT_COLOR_DESC),
          selectedColor: Color(prefs.theme.accentColor),
          onColorChange: (color) => prefs.setAccentColor(color.value),
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
          ],
        ),
        const ListDivider(),
        ListTileColor(
          title: translations.get(StringKey.NOTE_COLOR),
          description: translations.get(StringKey.NOTE_COLOR_DESC),
          selectedColor: Color(prefs.theme.noteColor),
          onColorChange: (color) => prefs.setNoteColor(color.value),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    translations = Translations.of(context);

    return AppbarPage(
      title: translations.get(StringKey.SETTINGS),
      body: ListView(
        children: [_buildSettingsGeneral(), _buildSettingsDisplay()],
      ),
    );
  }
}
