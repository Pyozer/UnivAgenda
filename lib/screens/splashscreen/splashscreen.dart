import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest_all.dart';

import '../../keys/string_key.dart';
import '../appbar_screen.dart';
import '../home/home.dart';
import '../login/login.dart';
import '../onboarding/onboarding.dart';
import '../../utils/analytics.dart';
import '../../utils/functions.dart';
import '../../utils/preferences/settings.provider.dart';
import '../../utils/translations.dart';
import '../../widgets/ui/button/raised_button_colored.dart';
import '../../widgets/ui/logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with AfterLayoutMixin {
  String? _errorMsg;

  @override
  void afterFirstLayout(BuildContext context) {
    _initPreferences();
    AnalyticsProvider.setScreen(widget);
  }

  Future<void> _initPreferences() async {
    final now = DateTime.now();

    // Init translations
    await i18n.init();

    // Init timezone
    initializeTimeZones();
    setLocalLocation(
      getLocation(await FlutterTimezone.getLocalTimezone()),
    );

    _setError(null);
    _startTimeout();

    if (!mounted) return;
    final prefs = context.read<SettingsProvider>();

    final routeDest = (!prefs.isIntroDone)
        ? const OnboardingScreen()
        : (prefs.appLaunchCounter > 0 && prefs.urlIcs.isEmpty)
            ? const HomeScreen()
            : const LoginScreen(isFromSettings: false);

    // Wait minimum 1.5 secondes
    final diffMs = 1000 - DateTime.now().difference(now).inMilliseconds;
    final waitTime = diffMs < 0 ? 0 : diffMs;

    await Future.delayed(Duration(milliseconds: waitTime));

    if (!mounted) return;
    navigatorPushReplace(context, routeDest);
  }

  void _startTimeout() async {
    // Start timout of 40sec. If widget still mounted, set error
    // If not mounted anymore, do nothing
    await Future.delayed(const Duration(seconds: 40));
    _setError(StrKey.NETWORK_ERROR);
  }

  void _setError([String? msgKey]) {
    if (!mounted) return;
    setState(() => _errorMsg = msgKey != null ? i18n.text(msgKey) : null);
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      body: Container(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Expanded(
              flex: 6,
              child: Center(child: Logo(size: 150.0)),
            ),
            Expanded(
              flex: 4,
              child: Center(
                child: _errorMsg != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMsg!,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24.0),
                          RaisedButtonColored(
                            text: i18n.text(StrKey.RETRY),
                            onPressed: _initPreferences,
                          ),
                        ],
                      )
                    : CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
