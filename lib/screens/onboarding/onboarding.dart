import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/logo.dart';

const double kIconSize = 150.0;

class OnboardingScreen extends StatefulWidget {
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends BaseState<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    setOnlyPortrait();
    AnalyticsProvider.setScreen(widget);
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          image,
          const SizedBox(height: 42.0),
        ],
      ),
    );
  }

  List<PageViewModel> _buildPages() {
    final pageDecoration = PageDecoration(
      dotsDecorator: DotsDecorator(
        size: const Size.fromRadius(5),
        activeSize: const Size.fromRadius(6),
        activeColor: theme.accentColor,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0)
      ),
    );

    return [
      PageViewModel(
        i18n.text(StrKey.INTRO_WELCOME_TITLE),
        i18n.text(StrKey.INTRO_WELCOME_DESC),
        image: _wrapImage(Logo(size: kIconSize)),
        decoration: pageDecoration,
      ),
      PageViewModel(
        i18n.text(StrKey.INTRO_LOGIN_TITLE),
        i18n.text(StrKey.INTRO_LOGIN_DESC),
        image: _wrapImage(Image.asset(Asset.INTRO_LOGIN, height: kIconSize)),
        decoration: pageDecoration,
      ),
      PageViewModel(
        i18n.text(StrKey.INTRO_AGENDA_TITLE),
        i18n.text(StrKey.INTRO_AGENDA_DESC),
        image: _wrapImage(Image.asset(Asset.INTRO_GROUP, height: kIconSize)),
        decoration: pageDecoration,
      ),
      PageViewModel(
        i18n.text(StrKey.INTRO_CUSTOM_TITLE),
        i18n.text(StrKey.INTRO_CUSTOM_DESC),
        image: _wrapImage(Image.asset(Asset.INTRO_THEME, height: kIconSize)),
        decoration: pageDecoration,
      ),
      PageViewModel(
        i18n.text(StrKey.INTRO_NOTE_TITLE),
        i18n.text(StrKey.INTRO_NOTE_DESC),
        image: _wrapImage(Image.asset(Asset.INTRO_NOTE, height: kIconSize)),
        decoration: pageDecoration,
      ),
      PageViewModel(
        i18n.text(StrKey.INTRO_EVENT_TITLE),
        i18n.text(StrKey.INTRO_EVENT_DESC),
        image: _wrapImage(Image.asset(Asset.INTRO_EVENT, height: kIconSize)),
        decoration: pageDecoration,
      ),
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
    return IntroductionScreen(
      pages: _buildPages(),
      onDone: _onDone,
      showSkipButton: true,
      skip: Text(i18n.text(StrKey.SKIP)),
      next: const Icon(Icons.arrow_forward),
      done: Text(i18n.text(StrKey.DONE)),
      skipFlex: 0,
      nextFlex: 0,
    );
  }
}
