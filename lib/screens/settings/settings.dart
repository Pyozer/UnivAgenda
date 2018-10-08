import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/models/analytics.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/widgets/settings/list_tile_choices.dart';
import 'package:myagenda/widgets/settings/list_tile_color.dart';
import 'package:myagenda/widgets/settings/list_tile_input.dart';
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

class _SettingsScreenState extends BaseState<SettingsScreen> {
  _forceRefreshResources() async {
    // Show progress dialog
    DialogPredefined.showProgressDialog(
      context,
      translations.get(StringKey.LOADING_RESOURCES),
    );

    final response = await HttpRequest.get(
      Url.resourcesUrl(prefs.university.resourcesFile),
    );

    if (response.isSuccess && mounted) {
      final resourcesGetStr = response.httpResponse.body;
      Map<String, dynamic> resourcesGet = json.decode(resourcesGetStr);
      if (resourcesGet.length > 0) {
        prefs.setResourcesDate();
        prefs.setResources(resourcesGet, true);
      }
    }
    // Send to analytics user force refresh calendar resources
    analyticsProvider.sendForceRefresh(AnalyticsValue.refreshResources);

    // Close loading dialog
    Navigator.pop(context);
  }

  Widget _buildSettingsGeneral() {
    final calendar = prefs.calendar;
    List<Widget> settingsGeneralElems;

    if (prefs.urlIcs == null) {
      settingsGeneralElems = [
          ListTileChoices(
            title: translations.get(StringKey.CAMPUS),
            titleDialog: translations.get(StringKey.SELECT_CAMPUS),
            selectedValue: calendar.campus,
            values: prefs.getAllCampus(),
            onChange: (value) => prefs.setCampus(value, true),
          ),
          const ListDivider(),
          ListTileChoices(
            title: translations.get(StringKey.DEPARTMENT),
            titleDialog: translations.get(StringKey.SELECT_DEPARTMENT),
            selectedValue: calendar.department,
            values: prefs.getCampusDepartments(calendar.campus),
            onChange: (value) => prefs.setDepartment(value, true),
          ),
          const ListDivider(),
          ListTileChoices(
            title: translations.get(StringKey.YEAR),
            titleDialog: translations.get(StringKey.SELECT_YEAR),
            selectedValue: calendar.year,
            values: prefs.getYears(calendar.campus, calendar.department),
            onChange: (value) => prefs.setYear(value, true),
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
            onChange: (value) => prefs.setGroup(value, true),
          )
        ];
    } else {
      settingsGeneralElems = [
        // TODO: Add real translations
        ListTileInput(
            title: translations.get(StringKey.GROUP),
            titleDialog: translations.get(StringKey.SELECT_GROUP),
            defaultValue: prefs.urlIcs,
            onChange: (value) => prefs.setUrlIcs(value, true),
          )
      ];
    }

    return SettingCard(
        header: translations.get(StringKey.SETTINGS_GENERAL),
        children: settingsGeneralElems,
      );
  }

  Widget _buildSettingsDisplay() {
    return SettingCard(
      header: translations.get(StringKey.SETTINGS_DISPLAY),
      children: [
        ListTileNumber(
          title: translations.get(StringKey.NUMBER_WEEK),
          defaultValue: prefs.numberWeeks,
          minValue: 1,
          maxValue: 16,
          onChange: (value) => prefs.setNumberWeeks(value, true),
        ),
        SwitchListTile(
          title: ListTileTitle(translations.get(StringKey.DISPLAY_ALL_DAYS)),
          subtitle: Text(translations.get(StringKey.DISPLAY_ALL_DAYS_DESC)),
          value: prefs.isDisplayAllDays,
          activeColor: theme.accentColor,
          onChanged: (value) => prefs.setDisplayAllDays(value, true),
        ),
        const ListDivider(),
        SwitchListTile(
          title:
              ListTileTitle(translations.get(StringKey.DISPLAY_HEADER_GROUP)),
          subtitle: Text(translations.get(StringKey.DISPLAY_HEADER_GROUP_DESC)),
          value: prefs.isHeaderGroupVisible,
          activeColor: theme.accentColor,
          onChanged: (value) => prefs.setHeaderGroupVisible(value, true),
        ),
      ],
    );
  }

  Widget _buildSettingsColors() {
    return SettingCard(
      header: translations.get(StringKey.SETTINGS_COLORS),
      children: [
        SwitchListTile(
          title: ListTileTitle(translations.get(StringKey.DARK_THEME)),
          subtitle: Text(translations.get(StringKey.DARK_THEME_DESC)),
          value: prefs.theme.darkTheme,
          activeColor: theme.accentColor,
          onChanged: (value) => prefs.setDarkTheme(value, true),
        ),
        const ListDivider(),
        ListTileColor(
          title: translations.get(StringKey.PRIMARY_COLOR),
          description: translations.get(StringKey.PRIMARY_COLOR_DESC),
          selectedColor: Color(prefs.theme.primaryColor),
          onColorChange: (color) => prefs.setPrimaryColor(color.value, true),
        ),
        const ListDivider(),
        ListTileColor(
          title: translations.get(StringKey.ACCENT_COLOR),
          description: translations.get(StringKey.ACCENT_COLOR_DESC),
          selectedColor: Color(prefs.theme.accentColor),
          onColorChange: (color) => prefs.setAccentColor(color.value, true),
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
          onColorChange: (color) => prefs.setNoteColor(color.value, true),
        ),
        SwitchListTile(
          title:
              ListTileTitle(translations.get(StringKey.GENERATE_EVENT_COLOR)),
          subtitle: Text(translations.get(StringKey.GENERATE_EVENT_COLOR_TEXT)),
          value: prefs.isGenerateEventColor,
          activeColor: Theme.of(context).accentColor,
          onChanged: (value) => prefs.setGenerateEventColor(value, true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
