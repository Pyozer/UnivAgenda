import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const kLoginURL = "https://cas.univ-lemans.fr/cas/login";

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _validateTextField(String value) {
    if (value.isEmpty) {
      return Translations.of(context).get(StringKey.REQUIRE_FIELD);
    }
    return null;
  }

  Future _onSubmit() async {
    if (_formKey.currentState.validate()) {
      // Get username and password from inputs
      final username = _usernameController.text;
      final password = _passwordController.text;

      // First request to get JSESSIONID cookie and lt value
      final response = await http.get(kLoginURL);

      // If request passed
      if (response.statusCode == 200) {
        final htmlResult = response.body;

        // Extract lt value from HTML
        String lt = getStringBetween(
            htmlResult, "<input type=\"hidden\" name=\"lt\" value=\"", "\" />");

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
        final loginResponse = await http
            .post(kLoginURL, body: postParams, headers: {"cookie": cookie});

        // Check if request passed
        if (loginResponse.statusCode == 200) {
          final htmlLoginResult = loginResponse.body;

          // Check if error
          bool isError =
              htmlLoginResult.contains("<div id=\"status\" class=\"errors\">");

          if (isError) {
            // Display error to user
            Preferences.setUserLogged(false);
            String error = getStringBetween(htmlLoginResult,
                    "<div id=\"status\" class=\"errors\">", "</div>")
                .trim();

            _scaffoldKey.currentState
                .showSnackBar(SnackBar(content: Text(error)));
          } else {
            // Login user if no error
            Preferences.setUserLogged(true);

            Navigator.of(context).pushReplacementNamed(RouteKey.HOME);
          }
        } else {
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("Erreur de connexion au serveur :/")));
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Erreur de connexion au serveur :/")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 16.0),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        Asset.LOGO,
                        width: 100.0,
                      ),
                      Container(height: 12.0),
                      Text(
                        translations.get(StringKey.APP_NAME),
                        style: Theme.of(context)
                            .textTheme
                            .title
                            .copyWith(fontSize: 28.0),
                      ),
                      Container(height: 64.0),
                      TextFormField(
                          validator: _validateTextField,
                          controller: _usernameController,
                          decoration:
                              InputDecoration(labelText: translations.get(StringKey.LOGIN_USERNAME))),
                      Container(height: 24.0),
                      TextFormField(
                        validator: _validateTextField,
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: translations.get(StringKey.LOGIN_PASSWORD)),
                      ),
                      Container(height: 32.0),
                      RaisedButtonColored(
                        onPressed: _onSubmit,
                        text: translations.get(StringKey.LOGIN_SUBMIT).toUpperCase(),
                      ),
                      Container(height: 32.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),);
  }
}
