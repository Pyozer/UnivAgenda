import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  void _onSubmit() {
    // TODO: Faire processus de connexion
  }


  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return Scaffold(
        body: Container(
      margin: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 16.0),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                  decoration: InputDecoration(
                      labelText: "Identifiant")
                ),
                Container(height: 24.0),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "Mot de passe"),
                ),
                Container(height: 32.0),
                RaisedButtonColored(
                  onPressed: _onSubmit,
                  text: "CONNEXION",
                ),
                Container(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}