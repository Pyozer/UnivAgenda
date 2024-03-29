import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

import '../../keys/assets.dart';
import '../../keys/string_key.dart';
import '../../utils/analytics.dart';
import '../../utils/functions.dart';
import '../../utils/preferences/settings.provider.dart';
import '../../utils/translations.dart';
import '../../widgets/ui/logo.dart';
import '../home/home.dart';
import '../login/login.dart';

const double kIconSize = 150.0;

class OnboardingScreen extends StatefulWidget {
  final bool shouldPopOnDone;

  const OnboardingScreen({Key? key, required this.shouldPopOnDone})
      : super(key: key);

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
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
        image: _wrapImage(const Logo(size: kIconSize)),
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

    if (widget.shouldPopOnDone) {
      Navigator.of(context).pop();
    } else {
      navigatorPushReplace(
        context,
        prefs.appLaunchCounter == 0 && prefs.urlIcs.isEmpty
            ? const LoginScreen(isFromSettings: false)
            : const HomeScreen(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return IntroductionScreen(
      pages: _buildPages(),
      onDone: _onDone,
      showSkipButton: true,
      skip: Text(i18n.text(StrKey.SKIP), style: TextStyle(color: color)),
      next: Icon(Icons.arrow_forward, color: color),
      done: Text(i18n.text(StrKey.DONE), style: TextStyle(color: color)),
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
