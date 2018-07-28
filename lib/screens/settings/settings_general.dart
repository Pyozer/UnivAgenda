import 'package:flutter/material.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/translate/translations.dart';

class SettingsGeneralScreen extends StatefulWidget {
  @override
  _SettingsGeneralScreenState createState() => new _SettingsGeneralScreenState();
}

class _SettingsGeneralScreenState extends State<SettingsGeneralScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      title: Translations.of(context).get(Translate.SETTINGS_DISPLAY),
      body: Text("test"),
    );
  }
}
