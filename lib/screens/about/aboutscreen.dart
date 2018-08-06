import 'package:flutter/material.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/translate/string_key.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/widgets/logo_app.dart';

class AboutScreen extends StatelessWidget {
  Widget _buildHeader(BuildContext context) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('MyAgenda', style: Theme.of(context).textTheme.title),
        LogoApp(),
        Text('1.0.0')
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return AppbarPage(
        title: translations.get(StringKey.ABOUT),
        body: Container(
            child: Expanded(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[_buildHeader(context)],
        ))));
  }
}
