import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/screens/home/home.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/login/login_base.dart';
import 'package:myagenda/utils/login/login_cas.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/list_divider.dart';
import 'package:myagenda/widgets/ui/dropdown.dart';
import 'package:myagenda/widgets/ui/logo.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseState<LoginScreen> {
  final _urlIcsController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordNode = FocusNode();

  bool _isLoading = false;

  String _selectedUniversity;

  @override
  void initState() {
    super.initState();
    setOnlyPortrait();
  }

  @override
  dispose() {
    _urlIcsController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordNode.dispose();
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
    setState(() => _isLoading = loading);
  }

  void _onSubmit() async {
    FocusScope.of(context).requestFocus(FocusNode());

    // Get username and password from inputs
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    String urlIcs = _urlIcsController.text.trim();

    // Check fields values
    if ((_isUrlIcs() && urlIcs.isEmpty) ||
        (!_isUrlIcs() && (username.isEmpty || password.isEmpty))) {
      _showMessage(i18n.text(StrKey.REQUIRE_FIELD));
      return;
    }

    _setLoading(true);
    prefs.setUserLogged(false);
    _startTimeout();

    if (!_isUrlIcs() && mounted) {
      prefs.setUniversity(_selectedUniversity);
      prefs.setUrlIcs(null);

      // Login process
      final baseLogin = LoginCAS(prefs.university, username, password);
      final loginResult = await baseLogin.login();

      if (!mounted) return;

      if (loginResult.result == LoginResultType.LOGIN_FAIL) {
        _setLoading(false);
        _showMessage(loginResult.message);
        return;
      } else if (loginResult.result == LoginResultType.NETWORK_ERROR) {
        _setLoading(false);
        _showMessage(
          i18n.text(StrKey.LOGIN_SERVER_ERROR, {
            'university': prefs.university.university,
          }),
        );
        return;
      } else if (loginResult.result != LoginResultType.LOGIN_SUCCESS) {
        _setLoading(false);
        _showMessage(i18n.text(StrKey.UNKNOWN_ERROR));
        return;
      }

      final response = await HttpRequest.get(prefs.university.resourcesFile);

      if (!mounted) return;

      if (!response.isSuccess) {
        _setLoading(false);
        _showMessage(i18n.text(StrKey.GET_RES_ERROR));
        return;
      }

      try {
        prefs.setResources(response.httpResponse.body);
      } catch (_) {
        _setLoading(false);
        _showMessage(i18n.text(StrKey.ERROR_JSON_PARSE));
        return;
      }
      prefs.setResourcesDate();
    } else if (mounted) {
      urlIcs = urlIcs.replaceFirst('webcal', 'http');
      prefs.setUrlIcs(urlIcs);

      final response = await HttpRequest.get(urlIcs);

      if (!mounted) return;

      if (!response.isSuccess) {
        _setLoading(false);
        _showMessage(i18n.text(StrKey.FILE_404));
        return;
      }
      String ical = utf8.decode(response.httpResponse.bodyBytes);
      if (!Ical(ical).isValidIcal()) {
        _setLoading(false);
        _showMessage(i18n.text(StrKey.WRONG_ICS_FORMAT));
        return;
      }
      prefs.setCachedIcal(ical);
    }

    await prefs.initResAndGroup();

    // Redirect user if no error
    prefs.setUserLogged(true);
    if (mounted)
      Navigator.of(context).pushReplacement(
        CustomRoute(builder: (_) => HomeScreen(isFromLogin: true)),
      );
  }

  void _showMessage(String msg) {
    DialogPredefined.showSimpleMessage(context, i18n.text(StrKey.ERROR), msg);
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    bool isObscure,
    TextEditingController controller,
    VoidCallback onEditComplete,
    TextInputAction inputAction, [
    FocusNode focusNode,
  ]) {
    return TextField(
      focusNode: focusNode,
      onEditingComplete: onEditComplete,
      controller: controller,
      textInputAction: inputAction,
      autofocus: false,
      obscureText: isObscure,
      maxLines: null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.accentColor),
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

  bool _isUrlIcs() {
    return _selectedUniversity == i18n.text(StrKey.OTHER);
  }

  void _onUniversitySelected(String value) {
    setState(() => _selectedUniversity = value);
    prefs.setUniversity(_isUrlIcs() ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    final urlICsInput = _buildTextField(
      i18n.text(StrKey.URL_ICS),
      OMIcons.event,
      false,
      _urlIcsController,
      _onSubmit,
      TextInputAction.done,
    );

    final username = _buildTextField(
      i18n.text(StrKey.LOGIN_USERNAME),
      OMIcons.person,
      false,
      _usernameController,
      () => FocusScope.of(context).requestFocus(_passwordNode),
      TextInputAction.next,
    );

    final password = _buildTextField(
      i18n.text(StrKey.LOGIN_PASSWORD),
      OMIcons.lock,
      true,
      _passwordController,
      _onSubmit,
      TextInputAction.done,
      _passwordNode,
    );

    final loginButton = FloatingActionButton(
      onPressed: _onSubmit,
      child: const Icon(Icons.send),
      backgroundColor: theme.accentColor,
    );

    var listUniversity = prefs.getAllUniversity();
    listUniversity.add(i18n.text(StrKey.OTHER));

    if (_selectedUniversity == null) {
      if (prefs.university != null && listUniversity.contains(prefs.university))
        _selectedUniversity = prefs.university.university;
      else
        _selectedUniversity = listUniversity[0];
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 10.0),
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
                      style: theme.textTheme.title.copyWith(fontSize: 26.0),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 11,
                child: Column(
                  children: [
                    Dropdown(
                      items: listUniversity,
                      value: _selectedUniversity,
                      onChanged: _onUniversitySelected,
                      isExpanded: false,
                    ),
                    Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Column(
                          children: _isUrlIcs()
                              ? [urlICsInput]
                              : [username, const ListDivider(), password],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    _isLoading ? const CircularProgressIndicator() : loginButton
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FlatButton(
                    child: Text(i18n.text(StrKey.DATA_PRIVACY)),
                    onPressed: _onDataPrivcacy,
                  ),
                  FlatButton(
                    child: Text(i18n.text(StrKey.HELP_FEEDBACK)),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(RouteKey.HELP),
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
