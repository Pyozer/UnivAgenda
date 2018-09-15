import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/translations.dart';

class SupportMeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    return AppbarPage(
      title: translations.get(StringKey.SUPPORTME),
      body: Container(),
    );
  }
}