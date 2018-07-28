import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myagenda/translate/translations.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translations.of(context);

    return Scaffold(
        appBar: AppBar(
            title: Text(translate.text(Translate.SETTINGS))
        ),
        body: Container(
          child: Center(
            child: Text(translate.text(Translate.SETTINGS)),
          )
        )
    );
  }
}