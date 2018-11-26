import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/widgets/ui/logo.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';

class SplashScreen extends StatefulWidget {
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends BaseState<SplashScreen> {
  bool _isError = false;
  String _errorMsg;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _initPreferences();
    });
  }

  void _initPreferences() async {
    _setError(false);
    _startTimeout();

    final startTime = DateTime.now();

    // Load preferences from disk
    await prefs.initFromDisk();

    // Update resources if they are empty or older than 6 hours
    int oldRes = DateTime.now().difference(prefs.resourcesDate).inHours.abs();

    // If university list is empty or cache is older than 6 hours
    if (prefs.listUniversity.length == 0 || oldRes >= 6) {
      // Request lastest university list
      final responseUniv = await HttpRequest.get(Url.listUniversity);
      // If request failed and there is no list University
      if (!responseUniv.isSuccess && prefs.listUniversity.length == 0) {
        _setError(true, StrKey.ERROR_UNIV_LIST_RETRIEVE_FAIL);
        return;
      }
      // Update university list
      if (responseUniv.httpResponse != null) {
        prefs.setListUniversityFromJSONString(responseUniv.httpResponse.body);
        prefs.setResourcesDate(startTime);
      }
    }

    // If list university still empty, set error
    if (prefs.listUniversity.length == 0) {
      _setError(true, StrKey.ERROR_UNIV_LIST_EMPTY);
      return;
    }
    // If user was connected but university or ics url are null, disconnect him
    if (prefs.urlIcs == null && prefs.university == null && prefs.isUserLogged)
      prefs.setUserLogged(false);

    // If university is null, take the first of list
    if (prefs.urlIcs == null && prefs.university == null)
      prefs.setUniversity(prefs.listUniversity[0].name);

    // If user is connected and have an university but no resources
    // Or same as top but with cache older than 6 hours
    if (prefs.isUserLogged &&
        prefs.urlIcs == null &&
        prefs.university != null &&
        (prefs.resources.length == 0 || oldRes >= 6)) {
      final responseRes = await HttpRequest.get(prefs.university.resourcesFile);

      if (!responseRes.isSuccess && prefs.resources.length == 0) {
        _setError(true, StrKey.ERROR_RES_LIST_RETRIEVE_FAIL);
        return;
      }

      // Update resources with new data get
      if (responseRes.httpResponse != null) {
        final resourcesGet = responseRes.httpResponse.body;
        prefs.setResources(resourcesGet);
        prefs.setResourcesDate(startTime);
      }
    }

    analyticsProvider.analytics.setUserId(prefs.installUID);
    prefs.forceSetState();

    final routeDest = (!prefs.isIntroDone)
        ? RouteKey.INTRO
        : (prefs.isUserLogged) ? RouteKey.HOME : RouteKey.LOGIN;

    // Wait minimum 1.5 secondes
    final diffMs = 1500 - DateTime.now().difference(startTime).inMilliseconds;
    final waitTime = diffMs < 0 ? 0 : diffMs;

    await Future.delayed(Duration(milliseconds: waitTime));
    _goToNext(routeDest);
  }

  void _startTimeout() async {
    // Start timout of 40sec. If widget still mounted, set error
    // If not mounted anymore, do nothing
    await Future.delayed(Duration(seconds: 40));
    _setError();
  }

  void _setError([bool isError = true, String errorMsgKey]) {
    if (mounted)
      setState(() {
        _isError = isError;
        _errorMsg = errorMsgKey != null ? translation(errorMsgKey) : null;
      });
  }

  void _goToNext(String route) {
    if (mounted) Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      body: Container(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 6,
              child: const Center(child: Logo(size: 150.0)),
            ),
            Expanded(
              flex: 4,
              child: Center(
                child: _isError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMsg ?? translation(StrKey.NETWORK_ERROR),
                            style: theme.textTheme.subhead,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24.0),
                          RaisedButtonColored(
                            text: translation(StrKey.RETRY),
                            onPressed: _initPreferences,
                          )
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
