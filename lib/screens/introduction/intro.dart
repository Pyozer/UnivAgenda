import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart' as IntroScreen;
import 'package:introduction_screen/model/page_view_model.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/logo.dart';

const double kIconSize = 150.0;

class IntroductionScreen extends StatefulWidget {
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends BaseState<IntroductionScreen> {
  @override
  void initState() {
    super.initState();
    setOnlyPortrait();
  }

  @override
  void dispose() {
    setAllOrientation();
    super.dispose();
  }

  void setOnlyPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void setAllOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Widget _wrapImage(Widget image) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        image,
        const SizedBox(height: 42.0),
      ],
    );
  }

  List<PageViewModel> _buildPages() {
    final dotActiveColor = theme.accentColor;
    final dotSize = const Size.fromRadius(6.5);

    return [
      PageViewModel(
        translations.text(StrKey.INTRO_WELCOME_TITLE),
        translations.text(StrKey.INTRO_WELCOME_DESC),
        _wrapImage(Logo(size: kIconSize)),
        progressSize: dotSize,
        progressColor: dotActiveColor,
      ),
      PageViewModel(
        translations.text(StrKey.INTRO_LOGIN_TITLE),
        translations.text(StrKey.INTRO_LOGIN_DESC),
        _wrapImage(Image.asset(Asset.INTRO_LOGIN, height: kIconSize)),
        progressSize: dotSize,
        progressColor: dotActiveColor,
      ),
      PageViewModel(
        translations.text(StrKey.INTRO_AGENDA_TITLE),
        translations.text(StrKey.INTRO_AGENDA_DESC),
        _wrapImage(Image.asset(Asset.INTRO_GROUP, height: kIconSize)),
        progressSize: dotSize,
        progressColor: dotActiveColor,
      ),
      PageViewModel(
        translations.text(StrKey.INTRO_CUSTOM_TITLE),
        translations.text(StrKey.INTRO_CUSTOM_DESC),
        _wrapImage(Image.asset(Asset.INTRO_THEME, height: kIconSize)),
        progressSize: dotSize,
        progressColor: dotActiveColor,
      ),
      PageViewModel(
        translations.text(StrKey.INTRO_NOTE_TITLE),
        translations.text(StrKey.INTRO_NOTE_DESC),
        _wrapImage(Image.asset(Asset.INTRO_NOTE, height: kIconSize)),
        progressSize: dotSize,
        progressColor: dotActiveColor,
      ),
      PageViewModel(
        translations.text(StrKey.INTRO_EVENT_TITLE),
        translations.text(StrKey.INTRO_EVENT_DESC),
        _wrapImage(Image.asset(Asset.INTRO_EVENT, height: kIconSize)),
        progressSize: dotSize,
        progressColor: dotActiveColor,
      ),
      PageViewModel(
        translations.text(StrKey.INTRO_OFFLINE_TITLE),
        translations.text(StrKey.INTRO_OFFLINE_DESC),
        _wrapImage(Image.asset(Asset.INTRO_INTERNET, height: kIconSize)),
        progressSize: dotSize,
        progressColor: dotActiveColor,
      )
    ];
  }

  void _onDone() {
    prefs.setIntroDone(true);
    Navigator.pushReplacementNamed(
      context,
      prefs.isUserLogged ? RouteKey.HOME : RouteKey.LOGIN,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroScreen.IntroductionScreen(
      pages: _buildPages(),
      onDone: _onDone,
      showSkipButton: true,
      skip: Text(translations.text(StrKey.SKIP)),
      next: const Icon(Icons.arrow_forward),
      done: Text(translations.text(StrKey.DONE)),
    );
  }
}
