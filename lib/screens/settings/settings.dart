import 'package:flutter/material.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/widgets/list_divider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return AppbarPage(
      title: translations.get(Translate.SETTINGS),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.group),
            title: Text(translations.get(Translate.SETTINGS_GENERAL)),
            onTap: () => Navigator.pushNamed(context, '/settings/general'),
          ),
          const ListDivider(),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: Text(translations.get(Translate.SETTINGS_DISPLAY)),
            onTap: () => Navigator.pushNamed(context, '/settings/display')
          )
        ]
      )
    );
  }
}