import 'package:flutter/material.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/translate/string_key.dart';
import 'package:myagenda/translate/translations.dart';

class AboutScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return AppbarPage(
      title: translations.get(StringKey.ABOUT),
      body: Container(
        child: Center(
          child: Text(Translations.of(context).get(StringKey.ABOUT)),
        )
      )
    );
  }
}