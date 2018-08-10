import 'package:flutter/material.dart';
import 'package:introduction_screen/model/page_view_model.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/logo_app.dart';
import 'package:introduction_screen/introduction.dart';

class IntroductionScreen extends StatelessWidget {

  static const double kIconSize = 175.0;

  List<PageViewModel> _buildPages(BuildContext context) {
    final translate = Translations.of(context);
    return [
      PageViewModel(
        translate.get(StringKey.INTRO_WELCOME_TITLE),
        translate.get(StringKey.INTRO_WELCOME_DESC),
        LogoApp(width: kIconSize),
      ),
      PageViewModel(
        translate.get(StringKey.INTRO_AGENDA_TITLE),
        translate.get(StringKey.INTRO_AGENDA_DESC),
        Image.network(
            "https://raw.githubusercontent.com/Pyozer/MyAgenda/master/app/src/main/res/mipmap-xxxhdpi/intro_group.png",
            height: kIconSize),
      ),
      PageViewModel(
        translate.get(StringKey.INTRO_CUSTOM_TITLE),
        translate.get(StringKey.INTRO_CUSTOM_DESC),
        Image.network(
            "https://raw.githubusercontent.com/Pyozer/MyAgenda/master/app/src/main/res/mipmap-xxxhdpi/intro_theme.png",
            height: kIconSize)
      ),
      PageViewModel(
        translate.get(StringKey.INTRO_NOTE_TITLE),
        translate.get(StringKey.INTRO_NOTE_DESC),
        Image.network(
            "https://raw.githubusercontent.com/Pyozer/MyAgenda/master/app/src/main/res/mipmap-xxxhdpi/intro_note.png",
            height: kIconSize),
      ),
      PageViewModel(
        translate.get(StringKey.INTRO_EVENT_TITLE),
        translate.get(StringKey.INTRO_EVENT_DESC),
        Image.network(
            "https://raw.githubusercontent.com/Pyozer/MyAgenda/master/app/src/main/res/mipmap-xxxhdpi/intro_event.png",
            height: kIconSize),
      ),
      PageViewModel(
        translate.get(StringKey.INTRO_OFFLINE_TITLE),
        translate.get(StringKey.INTRO_OFFLINE_DESC),
        Image.network(
            "https://raw.githubusercontent.com/Pyozer/MyAgenda/master/app/src/main/res/mipmap-xxxhdpi/intro_internet.png",
            height: kIconSize),
      )
    ];
  }

  void _onDone(BuildContext context) async {
    await Preferences.setFirstBoot(false);
    Navigator.pushReplacementNamed(context, RouteKey.HOME);
  }

  @override
  Widget build(BuildContext context) {
    return IntroScreen(
        pages: _buildPages(context),
        onDone: () => _onDone(context),
        showSkipButton: true
    ); //Material App
  }
}
