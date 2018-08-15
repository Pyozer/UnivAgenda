import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction.dart';
import 'package:introduction_screen/model/page_view_model.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';

class IntroductionScreen extends StatelessWidget {
  static const double kIconSize = 150.0;

  List<PageViewModel> _buildPages(BuildContext context) {
    final translate = Translations.of(context);
    return [
      PageViewModel(
        translate.get(StringKey.INTRO_WELCOME_TITLE),
        translate.get(StringKey.INTRO_WELCOME_DESC),
        Image.asset(Asset.LOGO, width: kIconSize),
      ),
      PageViewModel(
        translate.get(StringKey.INTRO_AGENDA_TITLE),
        translate.get(StringKey.INTRO_AGENDA_DESC),
        Image.asset(Asset.INTRO_GROUP, height: kIconSize),
      ),
      PageViewModel(
          translate.get(StringKey.INTRO_CUSTOM_TITLE),
          translate.get(StringKey.INTRO_CUSTOM_DESC),
          Image.asset(Asset.INTRO_THEME, height: kIconSize)),
      PageViewModel(
        translate.get(StringKey.INTRO_NOTE_TITLE),
        translate.get(StringKey.INTRO_NOTE_DESC),
        Image.asset(Asset.INTRO_NOTE, height: kIconSize),
      ),
      PageViewModel(
        translate.get(StringKey.INTRO_EVENT_TITLE),
        translate.get(StringKey.INTRO_EVENT_DESC),
        Image.asset(Asset.INTRO_EVENT, height: kIconSize),
      ),
      PageViewModel(
        translate.get(StringKey.INTRO_OFFLINE_TITLE),
        translate.get(StringKey.INTRO_OFFLINE_DESC),
        Image.asset(Asset.INTRO_INTERNET, height: kIconSize),
      )
    ];
  }

  void _onDone(BuildContext context) async {
    await Preferences.setFirstBoot(false);
    Navigator.pushReplacementNamed(context, RouteKey.HOME);
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translations.of(context);

    return IntroScreen(
        pages: _buildPages(context),
        onDone: () => _onDone(context),
        showSkipButton: true,
        skipText: translate.get(StringKey.SKIP),
        nextText: translate.get(StringKey.NEXT),
        doneText: translate.get(StringKey.DONE)); //Material App
  }
}
