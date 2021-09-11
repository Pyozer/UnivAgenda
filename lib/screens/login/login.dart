import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:univagenda/keys/assets.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/screens/help/help.dart';
import 'package:univagenda/screens/home/home.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/api/api.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:univagenda/utils/preferences.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:univagenda/widgets/ui/logo.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _urlIcsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setOnlyPortrait();
    AnalyticsProvider.setScreen(widget);
  }

  @override
  void dispose() {
    _urlIcsController.dispose();
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

  void _setLoading(bool loading) {
    if (mounted) setState(() => _isLoading = loading);
  }

  void _onSubmit() async {
    FocusScope.of(context).requestFocus(FocusNode());

    String urlIcs = _urlIcsController.text.trim();

    // Check fields values
    if (urlIcs.isEmpty) {
      _showMessage(i18n.text(StrKey.REQUIRE_FIELD));
      return;
    }

    _setLoading(true);
    final prefs = context.read<PrefsProvider>();
    prefs.setUserLogged(false);
    _startTimeout();

    if (mounted) {
      urlIcs = urlIcs.replaceFirst('webcal', 'http');
      prefs.setUrlIcs(urlIcs);

      try {
        final courses = await Api().getCoursesCustomIcal(urlIcs);

        if (!mounted) return;
        prefs.setCachedCourses(courses);
      } catch (e) {
        _setLoading(false);
        _showMessage(e.toString());
        return;
      }
    }

    await prefs.initResAndGroup();

    // Redirect user if no error
    prefs.setUserLogged(true);
    if (mounted) {
      navigatorPush(context, HomeScreen());
    }
  }

  void _scanQRCode() async {
    String icsUrl = 'https://google.com';
    try {
      Uri.parse(icsUrl); // Check QRCode content
      _urlIcsController.text = icsUrl;
    } catch (e) {
      _showMessage("Le QRCode ne semble pas contenir un lien valide.");
    }
  }

  void _showMessage(String msg) {
    DialogPredefined.showSimpleMessage(context, i18n.text(StrKey.ERROR), msg);
  }

  Widget _buildIcsField() {
    return TextField(
      controller: _urlIcsController,
      onEditingComplete: _onSubmit,
      textInputAction: TextInputAction.done,
      autofocus: false,
      maxLines: 2,
      minLines: 1,
      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.subtitle1,
        labelText: i18n.text(StrKey.URL_ICS),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIcon: Icon(
          Icons.event_outlined,
          color: Theme.of(context).accentColor,
        ),
        contentPadding: const EdgeInsets.fromLTRB(0.0, 18.0, 18.0, 18.0),
        border: InputBorder.none,
      ),
    );
  }

  void _startTimeout() async {
    // Start timout of 30sec. If widget still mounted, set error
    // If not mounted anymore, do nothing
    await Future.delayed(const Duration(seconds: 30));
    if (mounted) setState(() => _isLoading = false);
  }

  void _onDataPrivcacy() {
    DialogPredefined.showSimpleMessage(
      context,
      i18n.text(StrKey.DATA_PRIVACY),
      i18n.text(StrKey.DATA_PRIVACY_TEXT),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final qrCodeButton = FloatingActionButton(
      onPressed: _scanQRCode,
      child: Image.asset(
        Asset.QRCODE_WHITE,
        width: 24.0,
      ),
      backgroundColor: theme.accentColor,
      heroTag: 'qrcode_btn',
    );

    final loginButton = FloatingActionButton(
      onPressed: _onSubmit,
      child: const Icon(Icons.send),
      backgroundColor: theme.accentColor,
      heroTag: 'send_ical',
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Logo(size: 100.0),
                    const SizedBox(height: 12.0),
                    Text(
                      i18n.text(StrKey.APP_NAME),
                      style:
                          theme.textTheme.headline6!.copyWith(fontSize: 26.0),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 11,
                child: Column(
                  children: [
                    Card(
                      elevation: 4.0,
                      child: _buildIcsField(),
                    ),
                    const SizedBox(height: 24.0),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              qrCodeButton,
                              const SizedBox(width: 28.0),
                              Text(i18n.text(StrKey.OR)),
                              const SizedBox(width: 28.0),
                              loginButton
                            ],
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: Text(i18n.text(StrKey.DATA_PRIVACY)),
                    onPressed: _onDataPrivcacy,
                  ),
                  TextButton(
                    child: Text(i18n.text(StrKey.HELP_FEEDBACK)),
                    onPressed: () => navigatorPush(context, HelpScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
