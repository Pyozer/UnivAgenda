import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:univagenda/keys/assets.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/screens/home/home.dart';
import 'package:univagenda/screens/login/login.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/ui/logo.dart';

import '../../utils/preferences/theme.provider.dart';

const double kIconSize = 150.0;

class OnboardingScreen extends StatefulWidget {
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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
    return [
      PageViewModel(
        title: i18n.text(StrKey.INTRO_WELCOME_TITLE),
        body: i18n.text(StrKey.INTRO_WELCOME_DESC),
        image: _wrapImage(Logo(size: kIconSize)),
      ),
      PageViewModel(
        title: i18n.text(StrKey.INTRO_CUSTOM_TITLE),
        body: i18n.text(StrKey.INTRO_CUSTOM_DESC),
        image: _wrapImage(Image.asset(Asset.INTRO_THEME, height: kIconSize)),
      ),
      PageViewModel(
        title: i18n.text(StrKey.INTRO_NOTE_TITLE),
        body: i18n.text(StrKey.INTRO_NOTE_DESC),
        image: _wrapImage(Image.asset(Asset.INTRO_NOTE, height: kIconSize)),
      ),
      PageViewModel(
        title: i18n.text(StrKey.INTRO_EVENT_TITLE),
        body: i18n.text(StrKey.INTRO_EVENT_DESC),
        image: _wrapImage(Image.asset(Asset.INTRO_EVENT, height: kIconSize)),
      ),
    ];
  }

  void _onDone() {
    final prefs = context.read<SettingsProvider>();
    prefs.setIntroDone(true);
    navigatorPushReplace(
      context,
      prefs.isUserLogged ? HomeScreen() : LoginScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().darkTheme;
    final btnStyle = TextStyle(color: isDark ? Colors.white : Colors.black);

    return IntroductionScreen(
      pages: _buildPages(),
      onDone: _onDone,
      showSkipButton: true,
      skip: Text(i18n.text(StrKey.SKIP), style: btnStyle),
      next: Icon(Icons.arrow_forward, color: btnStyle.color),
      done: Text(i18n.text(StrKey.DONE), style: btnStyle),
      skipOrBackFlex: 0,
      nextFlex: 0,
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).colorScheme.secondary,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}