import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/list_divider.dart';
import 'package:myagenda/widgets/ui/dropdown.dart';
import 'package:http/http.dart' as http;

//const kLoginURL = "https://cas.univ-lemans.fr/cas/login";
const kLoginURL = "https://cas.univ-tours.fr/cas/login";

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

    final prefs = PreferencesProvider.of(context);

    String loginUrl = prefs.loginUrl;

    // First request to get JSESSIONID cookie and lt value
    http.Response response;
    try {
      response = await http.get(loginUrl);
    } catch (_) {
      setLoading(false);
      showMessage(Translations.of(context).get(StringKey.LOGIN_SERVER_ERROR));
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
    http.Response loginResponse;
    try {
      loginResponse = await http.post(
        loginUrl,
        body: postParams,
        headers: {"cookie": cookie},
      );
    } catch (_) {
      setLoading(false);
      showMessage(Translations.of(context).get(StringKey.LOGIN_SERVER_ERROR));
      return;
    }

    final htmlLogin = loginResponse.body;

    // Check if error
    bool isError = htmlLogin.contains("<div id=\"status\" class=\"errors\">");

    setLoading(false);

    if (isError) {
      // Display error to user
      prefs.setUserLogged(false, false);
      String error = getStringBetween(
        htmlLogin,
        "<div id=\"status\" class=\"errors\">",
        "</div>",
      ).trim();

      showMessage(error);
    } else {
      // Login user if no error
      prefs.setUserLogged(true, false);
      Navigator.of(context).pushReplacementNamed(RouteKey.HOME);
    }
  }

  void showMessage(String msg) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    final prefs = PreferencesProvider.of(context);
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
                    Dropdown(
                      items: prefs.getAllUniversity(),
                      value: prefs.university,
                      onChanged: (university) {
                        prefs.setUniversity(university);
                      },
                    ),
                    Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(8.0),
                        ),
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
                                    color: Colors.black54,
                                  ),
                                  Expanded(child: password)
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    _isLoading ? CircularProgressIndicator() : loginButton,
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
