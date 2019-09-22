import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/api/api.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/button/raised_button_colored.dart';
import 'package:myagenda/widgets/ui/logo.dart';
import 'package:timezone/timezone.dart';

class SplashScreen extends StatefulWidget {
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends BaseState<SplashScreen> with AfterLayoutMixin {
  String _errorMsg;

  @override
  void afterFirstLayout(BuildContext context) {
    _initPreferences();
    AnalyticsProvider.setScreen(widget);
  }

  Future<List<int>> loadDefaultData() async {
    final byteData = await rootBundle.load(
      'packages/timezone/data/2019b_all.tzf',
    );
    return byteData.buffer.asUint8List();
  }

  Future<void> _initPreferences() async {
    // Init translations
    await i18n.init();
    
    // Init timezone
    initializeDatabase(await loadDefaultData());
    setLocalLocation(
      getLocation(await FlutterNativeTimezone.getLocalTimezone()),
    );

    _setError(null);
    _startTimeout();

    final now = DateTime.now();

    // Load preferences from disk
    await prefs.initFromDisk(true);

    // If resources are older than 15min they need to be updated
    bool isListUnivOld = now.difference(prefs.resourcesDate).inMinutes > 15;

    // If university list is empty or cache is too old
    if (prefs.listUniversity.isEmpty || isListUnivOld) {
      // Request lastest university list
      try {
        final responseUniv = await Api().getResources();
        // Update university list
        prefs.setListUniversity(responseUniv);
        prefs.setResourcesDate(now);
      } catch (e) {
        print(e);
        // If request failed and there is no list University
        if (prefs.listUniversity.isEmpty)
          return _setError(StrKey.ERROR_UNIV_LIST_RETRIEVE_FAIL);
      }
    }

    // If list university still empty, set error
    if (prefs.listUniversity.isEmpty) {
      return _setError(StrKey.ERROR_UNIV_LIST_EMPTY);
    }
    // If user was connected but university or ics url are null, disconnect him
    if (prefs.urlIcs == null && prefs.university == null && prefs.isUserLogged)
      prefs.setUserLogged(false);

    // If university is null, take the first of list
    if (prefs.urlIcs == null && prefs.university == null)
      prefs.setUniversity(prefs.listUniversity[0].university);

    // If user is connected and have an university but no resources
    // Or same as top but with cache too older
    if (prefs.isUserLogged &&
        prefs.urlIcs == null &&
        prefs.university != null &&
        (prefs.resources.isEmpty || isListUnivOld)) {
      try {
        final responseRes = await Api().getUnivResources(
          prefs.university.id,
        );
        // Update resources with new data get
        prefs.setResources(responseRes);
        prefs.setResourcesDate(now);
      } catch (e) {
        if (prefs.resources.isEmpty) {
          return _setError(StrKey.ERROR_RES_LIST_RETRIEVE_FAIL);
        }
      }
    }

    final routeDest = (!prefs.isIntroDone)
        ? RouteKey.INTRO
        : (prefs.isUserLogged) ? RouteKey.HOME : RouteKey.LOGIN;

    // Wait minimum 1.5 secondes
    final diffMs = 1500 - DateTime.now().difference(now).inMilliseconds;
    final waitTime = diffMs < 0 ? 0 : diffMs;

    await Future.delayed(Duration(milliseconds: waitTime));
    if (mounted) Navigator.of(context).pushReplacementNamed(routeDest);
  }

  void _startTimeout() async {
    // Start timout of 40sec. If widget still mounted, set error
    // If not mounted anymore, do nothing
    await Future.delayed(const Duration(seconds: 40));
    _setError(StrKey.NETWORK_ERROR);
  }

  void _setError([String msgKey]) {
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
                            _errorMsg,
                            style: theme.textTheme.subhead,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24.0),
                          RaisedButtonColored(
                            text: i18n.text(StrKey.RETRY),
                            onPressed: _initPreferences,
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
