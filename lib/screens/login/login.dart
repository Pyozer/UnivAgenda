import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/login/login_base.dart';
import 'package:myagenda/utils/login/login_cas.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/list_divider.dart';
import 'package:myagenda/widgets/ui/dropdown.dart';
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
    setState(() {
      _isLoading = loading;
    });
  }

  void _onSubmit() async {
    FocusScope.of(context).requestFocus(FocusNode());

    // Get username and password from inputs
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final urlIcs = _urlIcsController.text.trim();

    // Check fields values
    if ((_isUrlIcs() && urlIcs.isEmpty) ||
        (!_isUrlIcs() && (username.isEmpty || password.isEmpty))) {
      _showMessage(translations.get(StringKey.REQUIRE_FIELD));
      return;
    }

    _setLoading(true);
    prefs.setUserLogged(false);
    _startTimeout();

    if (!_isUrlIcs()) {
      // Login process
      final loginResult =
          await LoginCAS(prefs.university.loginUrl, username, password).login();

      if (loginResult.result == LoginResultType.LOGIN_FAIL) {
        _setLoading(false);
        _showMessage(loginResult.message);
        return;
      } else if (loginResult.result == LoginResultType.NETWORK_ERROR) {
        _setLoading(false);
        _showMessage(
          translations
              .get(StringKey.LOGIN_SERVER_ERROR, [prefs.university.name]),
        );
        return;
      } else if (loginResult.result != LoginResultType.LOGIN_SUCCESS) {
        _setLoading(false);
        _showMessage(translations.get(StringKey.UNKNOWN_ERROR));
        return;
      }

      final response = await HttpRequest.get(
        Url.resourcesUrl(prefs.university.resourcesFile),
      );

      if (!response.isSuccess) {
        _setLoading(false);
        _showMessage(translations.get(StringKey.GET_RES_ERROR));
        return;
      }

      Map<String, dynamic> ressources = json.decode(response.httpResponse.body);
      prefs.setResources(ressources);
      prefs.setResourcesDate();
    } else {
      prefs.setUrlIcs(urlIcs);
      // TODO: Checker url fourni
    }

    await prefs.initResAndGroup();

    // Redirect user if no error
    prefs.setUserLogged(true);
    Navigator.of(context).pushReplacementNamed(RouteKey.HOME);
  }

  void _showMessage(String msg) {
    DialogPredefined.showSimpleMessage(
      context,
      translations.get(StringKey.ERROR),
      msg,
    );
  }

  Widget _buildTextField(
    hint,
    icon,
    isObscure,
    controller,
    onEditComplete,
    inputAction, [
    focusNode,
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
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDataPrivcacy() {
    DialogPredefined.showSimpleMessage(
      context,
      translations.get(StringKey.DATA_PRIVACY),
      translations.get(StringKey.DATA_PRIVACY_TEXT),
    );
  }

  bool _isUrlIcs() {
    return _selectedUniversity == translations.get(StringKey.OTHER);
  }

  void _onUniversitySelected(String value) {
    setState(() {
      _selectedUniversity = value;
    });
    prefs.setUniversity(_isUrlIcs() ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: Asset.LOGO,
      child: Image.asset(Asset.LOGO, width: 100.0),
    );

    final titleApp = Text(
      translations.get(StringKey.APP_NAME),
      style: theme.textTheme.title.copyWith(fontSize: 28.0),
    );

    final urlICsInput = _buildTextField(
      translations.get(StringKey.URL_ICS),
      OMIcons.event,
      false,
      _urlIcsController,
      _onSubmit,
      TextInputAction.done,
    );

    final username = _buildTextField(
      translations.get(StringKey.LOGIN_USERNAME),
      OMIcons.person,
      false,
      _usernameController,
      () => FocusScope.of(context).requestFocus(_passwordNode),
      TextInputAction.next,
    );

    final password = _buildTextField(
      translations.get(StringKey.LOGIN_PASSWORD),
      OMIcons.lock,
      true,
      _passwordController,
      _onSubmit,
      TextInputAction.done,
      _passwordNode,
    );

    final loginButton = FloatingActionButton(
      onPressed: _onSubmit,
      child: const Icon(OMIcons.send),
      backgroundColor: theme.accentColor,
    );

    var listUniversity = prefs.getAllUniversity();
    listUniversity.add(translations.get(StringKey.OTHER));

    if (_selectedUniversity == null) _selectedUniversity = listUniversity[0];

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
              left: 32.0, top: 32.0, right: 32.0, bottom: 8.0),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    logo,
                    const SizedBox(height: 8.0),
                    titleApp,
                    const SizedBox(height: 42.0),
                    Dropdown(
                      items: listUniversity,
                      value: _selectedUniversity,
                      onChanged: _onUniversitySelected,
                    ),
                    Card(
                      shape: const OutlineInputBorder(),
                      elevation: 4.0,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: Column(
                            children: (_isUrlIcs())
                                ? [urlICsInput]
                                : [username, const ListDivider(), password],
                          )),
                    ),
                    const SizedBox(height: 32.0),
                    _isLoading ? const CircularProgressIndicator() : loginButton
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              Wrap(
                spacing: 8.0,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text(translations.get(StringKey.DATA_PRIVACY)),
                    onPressed: _onDataPrivcacy,
                  ),
                  FlatButton(
                    child: Text(translations.get(StringKey.HELP_FEEDBACK)),
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
