import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/login/login_base.dart';
import 'package:myagenda/utils/login/login_cas.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/list_divider.dart';
import 'package:myagenda/widgets/ui/dropdown.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordNode = FocusNode();

  bool _isLoading = false;

  String university;

  @override
  void initState() {
    super.initState();
    setOnlyPortrait();
  }

  @override
  dispose() {
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
    final translations = Translations.of(context);
    FocusScope.of(context).requestFocus(FocusNode());

    // Get username and password from inputs
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Check fields values
    if (username.isEmpty || password.isEmpty) {
      _showMessage(translations.get(StringKey.REQUIRE_FIELD));
      return;
    }

    _setLoading(true);

    final prefs = PreferencesProvider.of(context);
    prefs.setUserLogged(false, false);
    
    _startTimeout();
    
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
        translations.get(StringKey.LOGIN_SERVER_ERROR, [prefs.university.name]),
      );
      return;
    } else if (loginResult.result != LoginResultType.LOGIN_SUCCESS) {
      _setLoading(false);
      _showMessage("Unknown error :/");
      return;
    }

    final response = await HttpRequest.get(
      Url.resourcesUrl(prefs.university.resourcesFile),
    );

    if (!response.isSuccess) {
      _setLoading(false);
      _showMessage("Error during retrieve agenda resources :/");
      return;
    }

    Map<String, dynamic> ressources = json.decode(response.httpResponse.body);
    prefs.setResources(ressources, false);
    prefs.setResourcesDate();

    await prefs.initResAndGroup();

    _scaffoldKey.currentState.removeCurrentSnackBar();
    // Redirect user if no error
    prefs.setUserLogged(true, false);
    Navigator.of(context).pushReplacementNamed(RouteKey.HOME);
  }

  void _showMessage(String msg) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
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
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Theme.of(context).accentColor),
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
        border: InputBorder.none,
      ),
    );
  }

  void _startTimeout() async {
    // Start timout of 1 minutes. If widget still mounted, set error
    // If not mounted anymore, do nothing
    await Future.delayed(Duration(minutes: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    final theme = Theme.of(context);
    final prefs = PreferencesProvider.of(context);

    final logo = Hero(
      tag: Asset.LOGO,
      child: Image.asset(Asset.LOGO, width: 100.0),
    );

    final titleApp = Text(
      translations.get(StringKey.APP_NAME),
      style: theme.textTheme.title.copyWith(fontSize: 28.0),
    );

    final username = _buildTextField(
      translations.get(StringKey.LOGIN_USERNAME),
      Icons.person_outline,
      false,
      _usernameController,
      () => FocusScope.of(context).requestFocus(_passwordNode),
      TextInputAction.next,
    );

    final password = _buildTextField(
      translations.get(StringKey.LOGIN_PASSWORD),
      Icons.lock_outline,
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
    if (prefs.university == null) prefs.setUniversity(listUniversity[0]);

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
              left: 32.0, top: 32.0, right: 32.0, bottom: 8.0),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [logo, const SizedBox(height: 8.0), titleApp],
                ),
                flex: 3,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Dropdown(
                      items: prefs.getAllUniversity(),
                      value: prefs.university.name,
                      onChanged: (value) => prefs.setUniversity(value, true),
                    ),
                    Card(
                      shape: const OutlineInputBorder(),
                      elevation: 4.0,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: Column(
                            children: [username, const ListDivider(), password],
                          )),
                    ),
                    const SizedBox(height: 32.0),
                    _isLoading ? CircularProgressIndicator() : loginButton
                  ],
                ),
                flex: 7,
              ),
              const SizedBox(height: 12.0),
              FlatButton(
                child: Text(translations.get(StringKey.HELP_FEEDBACK)),
                onPressed: () => Navigator.of(context).pushNamed(RouteKey.HELP),
              )
            ],
          ),
        ),
      ),
    );
  }
}
