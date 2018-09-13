import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
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
  bool _orientationDefined = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set screen only portrait of height is less than 600
    if (!_orientationDefined) {
      final media = MediaQuery.of(context);

      if (media.orientation == Orientation.portrait && media.size.width < 600) {
        setOnlyPortrait();
      } else if (media.orientation == Orientation.landscape &&
          media.size.height < 600) {
        setOnlyPortrait();
      } else {
        setAllOrientation();
      }
      _orientationDefined = true;
    }
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

    // Login process
    final loginResult =
        await LoginCAS(prefs.loginUrl, username, password).login();

    _setLoading(false);

    if (loginResult.result == LoginResultType.LOGIN_FAIL) {
      _showMessage(loginResult.message);
    } else if (loginResult.result == LoginResultType.NETWORK_ERROR) {
      _showMessage(
        translations.get(StringKey.LOGIN_SERVER_ERROR, [prefs.university]),
      );
    } else if (loginResult.result == LoginResultType.LOGIN_SUCCESS) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      // Redirect user if no error
      prefs.setUserLogged(true, false);
      Navigator.of(context).pushReplacementNamed(RouteKey.HOME);
    } else {
      _showMessage("Unknown error :/");
    }
  }

  void _showMessage(String msg) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildTextField(hint, icon, isObscure, controller, onEditComplete, inputAction,
      [focusNode]) {
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
                      onChanged: prefs.setUniversity,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
