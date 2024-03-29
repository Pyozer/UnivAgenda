import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../keys/pref_key.dart';
import '../../keys/string_key.dart';
import '../../utils/analytics.dart';
import '../../utils/functions.dart';
import '../../utils/preferences/settings.provider.dart';
import '../../utils/preferences/theme.provider.dart';
import '../../utils/translations.dart';
import '../../widgets/settings/list_tile_choices.dart';
import '../../widgets/settings/list_tile_color.dart';
import '../../widgets/settings/list_tile_input.dart';
import '../../widgets/settings/list_tile_number.dart';
import '../../widgets/settings/list_tile_title.dart';
import '../../widgets/settings/setting_card.dart';
import '../../widgets/ui/button/raised_button_colored.dart';
import '../appbar_screen.dart';
import '../login/login.dart';
import 'manage_hidden_events.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsProvider.setScreen(widget);
  }

  Widget _buildSettingsGeneral(SettingsProvider prefs) {
    List<Widget> settingsGeneralElems = [];

    // Copy ics url list
    final urlsIcs = List<String>.from(prefs.urlIcs);

    for (var i = 0; i < urlsIcs.length; i++) {
      settingsGeneralElems.add(ListTileInput(
        title: '${i18n.text(StrKey.URL_ICS)} #${i + 1}',
        hintText: i18n.text(StrKey.URL_ICS),
        defaultValue: urlsIcs[i],
        suffix: IconButton(
          onPressed: () {
            urlsIcs.removeAt(i);
            prefs.setUrlIcs(urlsIcs, true);
          },
          icon: const Icon(Icons.delete_outline),
        ),
        onChange: (value) {
          // Clean cached courses
          prefs.setCachedCourses(PrefKey.defaultCachedCourses);
          // Update url
          urlsIcs[i] = value;
          prefs.setUrlIcs(urlsIcs, true);
        },
      ));
    }

    // Display add calendar button
    if (urlsIcs.isEmpty || urlsIcs.every((url) => url.isNotEmpty)) {
      settingsGeneralElems.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: RaisedButtonColored(
              text: i18n.text(StrKey.ADD_CALENDAR),
              onPressed: () async {
                final icsUrl = await navigatorPush(
                  context,
                  const LoginScreen(isFromSettings: true),
                );
                if (icsUrl != null) {
                  urlsIcs.add(icsUrl);
                  prefs.setUrlIcs(urlsIcs, true);
                }
              },
            ),
          ),
        ),
      );
    }

    return SettingCard(
      header: i18n.text(StrKey.SETTINGS_GENERAL),
      children: settingsGeneralElems,
    );
  }

  Widget _buildSettingsDisplay(SettingsProvider prefs, ThemeData theme) {
    List<Widget> settingsDisplayItems = [
      ListTileNumber(
        title: i18n.text(StrKey.NUMBER_WEEK),
        subtitle: i18n.text(
          prefs.numberWeeks > 1
              ? StrKey.NUMBER_WEEK_DESC_PLURAL
              : StrKey.NUMBER_WEEK_DESC_ONE,
          {'nbWeeks': prefs.numberWeeks},
        ),
        defaultValue: prefs.numberWeeks,
        minValue: 1,
        maxValue: 16,
        onChange: (value) => prefs.setNumberWeeks(value, true),
      ),
      SwitchListTile(
        title: ListTileTitle(i18n.text(StrKey.DAYS_BEFORE)),
        subtitle: Text(i18n.text(StrKey.DAYS_BEFORE_DESC)),
        value: prefs.isPreviousCourses,
        activeColor: theme.colorScheme.secondary,
        onChanged: (value) => prefs.setShowPreviousCourses(value, true),
      ),
      SwitchListTile(
        title: ListTileTitle(i18n.text(StrKey.DISPLAY_ALL_DAYS)),
        subtitle: Text(i18n.text(StrKey.DISPLAY_ALL_DAYS_DESC)),
        value: prefs.isDisplayAllDays,
        activeColor: theme.colorScheme.secondary,
        onChanged: (value) => prefs.setDisplayAllDays(value, true),
      ),
      SwitchListTile(
        title: ListTileTitle(i18n.text(StrKey.HIDDEN_EVENT)),
        subtitle: Text(i18n.text(StrKey.FULL_HIDDEN_EVENT_DESC)),
        value: prefs.isFullHiddenEvent,
        activeColor: theme.colorScheme.secondary,
        onChanged: (value) => prefs.setFullHiddenEvent(value, true),
      ),
      ListTile(
        title: ListTileTitle(i18n.text(StrKey.MANAGE_HIDDEN_EVENT)),
        subtitle: Text(i18n.text(StrKey.MANAGE_HIDDEN_EVENT_DESC)),
        onTap: () {
          navigatorPush(
            context,
            const ManageHiddenEvents(),
            fullscreenDialog: true,
          );
        },
      )
    ];

    return SettingCard(
      header: i18n.text(StrKey.SETTINGS_DISPLAY),
      children: settingsDisplayItems,
    );
  }

  Widget _buildSettingsColors(
      SettingsProvider prefs, ThemeProvider themeProvider, ThemeData theme) {
    return SettingCard(
      header: i18n.text(StrKey.SETTINGS_COLORS),
      children: [
        ListTileChoices(
          title: i18n.text(StrKey.THEME),
          selectedValue: themeProvider.themeMode.name,
          values: [
            ThemeMode.system.name,
            ThemeMode.light.name,
            ThemeMode.dark.name
          ],
          buildTitle: (value) {
            if (value == ThemeMode.system.name) {
              return i18n.text(StrKey.SYSTEM_THEME);
            }
            if (value == ThemeMode.dark.name) {
              return i18n.text(StrKey.DARK_THEME);
            }
            return i18n.text(StrKey.LIGHT_THEME);
          },
          onChange: (value) {
            themeProvider.setThemeModeFromString(value, true);
          },
        ),
        ListTileColor(
          title: i18n.text(StrKey.PRIMARY_COLOR),
          description: i18n.text(StrKey.PRIMARY_COLOR_DESC),
          selectedColor: themeProvider.primaryColor,
          onColorChange: (color) => themeProvider.setPrimaryColor(color, true),
        ),
        ListTileColor(
          title: i18n.text(StrKey.ACCENT_COLOR),
          description: i18n.text(StrKey.ACCENT_COLOR_DESC),
          selectedColor: themeProvider.accentColor,
          onColorChange: (color) => themeProvider.setAccentColor(color, true),
          colors: const [
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
        ListTileColor(
          title: i18n.text(StrKey.NOTE_COLOR),
          description: i18n.text(StrKey.NOTE_COLOR_DESC),
          selectedColor: themeProvider.noteColor,
          onColorChange: (color) => themeProvider.setNoteColor(color, true),
        ),
        SwitchListTile(
          title: ListTileTitle(i18n.text(StrKey.GENERATE_EVENT_COLOR)),
          subtitle: Text(i18n.text(StrKey.GENERATE_EVENT_COLOR_TEXT)),
          value: prefs.isGenerateEventColor,
          activeColor: Theme.of(context).colorScheme.secondary,
          onChanged: (value) => prefs.setGenerateEventColor(value, true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<SettingsProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return AppbarPage(
      title: i18n.text(StrKey.SETTINGS),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0, bottom: 32.0),
        children: [
          _buildSettingsGeneral(prefs),
          _buildSettingsDisplay(prefs, theme),
          _buildSettingsColors(prefs, themeProvider, theme)
        ],
      ),
    );
  }
}
