import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/circular_loader.dart';
import 'package:myagenda/widgets/ui/list_divider.dart';
import 'package:http/http.dart' as http;

const kLoginURL = "https://cas.univ-lemans.fr/cas/login";

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _onSubmit() async {
    // Get username and password from inputs
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Check fields values
    if (username.isEmpty || password.isEmpty) {
      showMessage(Translations.of(context).get(StringKey.REQUIRE_FIELD));
      return;
    }

    setLoading(true);

    // First request to get JSESSIONID cookie and lt value
    final response = await http.get(kLoginURL);

    // If request failed
    if (response.statusCode != 200) {
      setLoading(false);
      showMessage(Translations.of(context).get(StringKey.APP_NAME));
      return;
    }

    final htmlResult = response.body;

    // Extract lt value from HTML
    String lt = getStringBetween(
      htmlResult,
      "<input type=\"hidden\" name=\"lt\" value=\"",
      "\" />",
    );

    // POST data
    Map<String, String> postParams = {
      "_eventId": "submit",
      "lt": lt,
      "submit": "LOGIN",
      "username": username,
      "password": password
    };

    // Get JSESSIONID from previous request header
    final cookie = response.headers["set-cookie"];

    // Second request, with all necessary data
    final loginResponse = await http.post(
      kLoginURL,
      body: postParams,
      headers: {"cookie": cookie},
    );

    // If request failed
    if (loginResponse.statusCode != 200) {
      setLoading(false);
      showMessage(Translations.of(context).get(StringKey.APP_NAME));
      return;
    }

    final htmlLogin = loginResponse.body;

    // Check if error
    bool isError = htmlLogin.contains("<div id=\"status\" class=\"errors\">");

    setLoading(false);

    if (isError) {
      // Display error to user
      Preferences.setUserLogged(false);
      String error = getStringBetween(
        htmlLogin,
        "<div id=\"status\" class=\"errors\">",
        "</div>",
      ).trim();

      showMessage(error);
    } else {
      // Login user if no error
      Preferences.setUserLogged(true);
      Navigator.of(context).pushReplacementNamed(RouteKey.HOME);
    }
  }

  void showMessage(String msg) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    final orientation = MediaQuery.of(context).orientation;

    final logo = Hero(
      tag: Asset.LOGO,
      child: Image.asset(Asset.LOGO, width: 100.0),
    );

    final titleApp = Text(
      translations.get(StringKey.APP_NAME),
      style: Theme.of(context).textTheme.title.copyWith(fontSize: 28.0),
    );

    final username = TextField(
      controller: _usernameController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: translations.get(StringKey.LOGIN_USERNAME),
        prefixIcon: const Icon(Icons.person_outline),
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
        border: InputBorder.none,
      ),
    );

    final password = TextField(
      controller: _passwordController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: translations.get(StringKey.LOGIN_PASSWORD),
        prefixIcon: const Icon(Icons.lock_outline),
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
        border: InputBorder.none,
      ),
    );

    final loginButton = FloatingActionButton(
      onPressed: _onSubmit,
      child: const Icon(Icons.send),
    );

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(32.0),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [logo, titleApp],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: (orientation == Orientation.portrait)
                            ? Column(
                                children: [
                                  username,
                                  const ListDivider(),
                                  password
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: username),
                                  Container(
                                      height: 32.0,
                                      width: 1.0,
                                      color: Colors.black54),
                                  Expanded(child: password)
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    _isLoading ? CircularLoader() : loginButton,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
