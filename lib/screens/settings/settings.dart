import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/settings/list_tile_choices.dart';
import 'package:myagenda/widgets/settings/list_tile_color.dart';
import 'package:myagenda/widgets/settings/list_tile_number.dart';
import 'package:myagenda/widgets/settings/list_tile_title.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/list_divider.dart';
import 'package:myagenda/widgets/ui/setting_card.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

enum MenuItem { REFRESH }

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  _forceRefreshResources() async {
    final translate = Translations.of(context);
    // Show progress dialog
    DialogPredefined.showProgressDialog(
      context,
      translate.get(StringKey.LOADING_RESOURCES),
    );

    final prefs = PreferencesProvider.of(context);

    final response = await HttpRequest.get(
      Url.resourcesUrl(prefs.university.resourcesFile),
    );

    if (response.isSuccess && mounted) {
      final resourcesGetStr = response.httpResponse.body;
      Map<String, dynamic> resourcesGet = json.decode(resourcesGetStr);
      if (resourcesGet.length > 0) {
        prefs.setResources(resourcesGet);
        prefs.setResourcesDate();
      }
    }
    // Close loading dialog
    Navigator.pop(context);
  }

  Widget _buildSettingsGeneral() {
    final translations = Translations.of(context);
    final prefs = PreferencesProvider.of(context);
    final calendar = prefs.calendar;

    return SettingCard(
      header: translations.get(StringKey.SETTINGS_GENERAL),
      children: [
        ListTileChoices(
          title: translations.get(StringKey.CAMPUS),
          titleDialog: translations.get(StringKey.SELECT_CAMPUS),
          selectedValue: calendar.campus,
          values: prefs.getAllCampus(),
          onChange: (value) => prefs.setCampus(value),
        ),
        const ListDivider(),
        ListTileChoices(
          title: translations.get(StringKey.DEPARTMENT),
          titleDialog: translations.get(StringKey.SELECT_DEPARTMENT),
          selectedValue: calendar.department,
          values: prefs.getCampusDepartments(calendar.campus),
          onChange: (value) => prefs.setDepartment(value),
        ),
        const ListDivider(),
        ListTileChoices(
          title: translations.get(StringKey.YEAR),
          titleDialog: translations.get(StringKey.SELECT_YEAR),
          selectedValue: calendar.year,
          values: prefs.getYears(calendar.campus, calendar.department),
          onChange: (value) => prefs.setYear(value),
        ),
        const ListDivider(),
        ListTileChoices(
          title: translations.get(StringKey.GROUP),
          titleDialog: translations.get(StringKey.SELECT_GROUP),
          selectedValue: calendar.group,
          values: prefs.getGroups(
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
    final translations = Translations.of(context);
    final prefs = PreferencesProvider.of(context);

    return SettingCard(
      header: translations.get(StringKey.SETTINGS_DISPLAY),
      children: [
        ListTileNumber(
          title: translations.get(StringKey.NUMBER_WEEK),
          defaultValue: prefs.numberWeeks,
          minValue: 1,
          maxValue: 16,
          inputType:
              TextInputType.numberWithOptions(decimal: false, signed: true),
          onChange: prefs.setNumberWeeks,
        ),
        SwitchListTile(
          title: ListTileTitle(translations.get(StringKey.DISPLAY_ALL_DAYS)),
          subtitle: Text(translations.get(StringKey.DISPLAY_ALL_DAYS_DESC)),
          value: prefs.isDisplayAllDays,
          activeColor: Theme.of(context).accentColor,
          onChanged: (value) => prefs.setDisplayAllDays(value),
        ),
        const ListDivider(),
        SwitchListTile(
          title:
              ListTileTitle(translations.get(StringKey.DISPLAY_HEADER_GROUP)),
          subtitle: Text(translations.get(StringKey.DISPLAY_HEADER_GROUP_DESC)),
          value: prefs.isHeaderGroupVisible,
          activeColor: Theme.of(context).accentColor,
          onChanged: (value) => prefs.setHeaderGroupVisible(value),
        ),
      ],
    );
  }

  Widget _buildSettingsColors() {
    final translations = Translations.of(context);
    final prefs = PreferencesProvider.of(context);

    return SettingCard(
      header: translations.get(StringKey.SETTINGS_COLORS),
      children: [
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
    final translations = Translations.of(context);

    return AppbarPage(
      title: translations.get(StringKey.SETTINGS),
      actions: <Widget>[
        PopupMenuButton<MenuItem>(
          icon: const Icon(OMIcons.moreVert),
          onSelected: (MenuItem result) {
            if (result == MenuItem.REFRESH) _forceRefreshResources();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
                PopupMenuItem<MenuItem>(
                  value: MenuItem.REFRESH,
                  child: Text(translations.get(StringKey.REFRESH_AGENDAS)),
                ),
              ],
        )
      ],
      body: ListView(
        children: [
          _buildSettingsGeneral(),
          _buildSettingsDisplay(),
          _buildSettingsColors()
        ],
      ),
    );
  }
}
