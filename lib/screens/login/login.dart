import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/list_divider.dart';
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

    final orientation = MediaQuery.of(context).orientation;

    final logo = Hero(
      tag: Asset.LOGO,
      child: Image.asset(Asset.LOGO, width: 100.0),
    );

    final titleApp = Text(
      translations.get(StringKey.APP_NAME),
      style: Theme.of(context).textTheme.title.copyWith(fontSize: 28.0),
    );

    final username = TextFormField(
      validator: _validateTextField,
      controller: _usernameController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: translations.get(StringKey.LOGIN_USERNAME),
        prefixIcon: const Icon(Icons.person_outline),
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
        border: InputBorder.none,
      ),
    );

    final password = TextFormField(
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
        body: Padding(
      padding: const EdgeInsets.all(32.0),
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
                    child: orientation == Orientation.portrait
                        ? Column(
                            children: [username, const ListDivider(), password],
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
                loginButton,
              ],
            ),
          ),
        ],
      ),
    ));
/*
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          Asset.LOGO,
                          width: 100.0,
                        ),
                        const Padding(
                            padding: const EdgeInsets.only(top: 12.0)),
                        Text(
                          translations.get(StringKey.APP_NAME),
                          style: Theme.of(context)
                              .textTheme
                              .title
                              .copyWith(fontSize: 28.0),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64.0),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: _validateTextField,
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText:
                                  translations.get(StringKey.LOGIN_USERNAME),
                            ),
                          ),
                          const Padding(
                              padding: const EdgeInsets.only(top: 16.0)),
                          TextFormField(
                            validator: _validateTextField,
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText:
                                    translations.get(StringKey.LOGIN_PASSWORD)),
                          ),
                          const Padding(
                              padding: const EdgeInsets.only(top: 32.0)),
                          RaisedButtonColored(
                            onPressed: _onSubmit,
                            text: translations
                                .get(StringKey.LOGIN_SUBMIT)
                                .toUpperCase(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );*/
  }
}
