import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/button/raised_button_colored.dart';
import 'package:myagenda/widgets/ui/logo.dart';

class SplashScreen extends StatefulWidget {
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends BaseState<SplashScreen>
    with AfterLayoutMixin<SplashScreen> {
  String _errorMsg;

  @override
  void afterFirstLayout(BuildContext context) {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
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
      final responseUniv = await HttpRequest.get(Url.listUniversity);
      // If request failed and there is no list University
      if (!responseUniv.isSuccess && prefs.listUniversity.isEmpty) {
        return _setError(StrKey.ERROR_UNIV_LIST_RETRIEVE_FAIL);
      }
      // Update university list
      if (responseUniv.httpResponse != null) {
        prefs.setListUniversityFromJSONString(responseUniv.httpResponse.body);
        prefs.setResourcesDate(now);
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
      final responseRes = await HttpRequest.get(prefs.university.resourcesFile);

      if (!responseRes.isSuccess && prefs.resources.isEmpty) {
        return _setError(StrKey.ERROR_RES_LIST_RETRIEVE_FAIL);
      }

      // Update resources with new data get
      if (responseRes.httpResponse != null) {
        final resourcesGet = responseRes.httpResponse.body;
        prefs.setResources(resourcesGet);
        prefs.setResourcesDate(now);
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
