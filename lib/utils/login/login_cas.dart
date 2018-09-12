import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:myagenda/utils/login/login_base.dart';

class LoginCAS extends LoginProcess {

  LoginCAS(loginUrl, username, password) : super(loginUrl, username, password);

  Future<LoginResult> login() async {
    http.Response response;
    try {
      response = await http.get(loginUrl);
    } catch (_) {
      return LoginResult(LoginResultType.NETWORK_ERROR);
    }

    final document = parse(response.body);

    // Extract lt value from HTML
    final ltInput = document.querySelector('input[name="lt"]');
    String lt = "";
    if (ltInput?.attributes?.containsKey("value") ?? false)
      lt = ltInput.attributes['value'];

    // POST data
    Map<String, String> postParams = {
      "_eventId": "submit",
      "lt": lt,
      "submit": "LOGIN",
      "username": username,
      "password": password,
      "execution": "e1s1"
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
      return LoginResult(LoginResultType.NETWORK_ERROR);
    }

    final loginDocument = parse(loginResponse.body);
    final errorElement = loginDocument.querySelector(".errors");
    final successElement = loginDocument.querySelector(".success");

    if (errorElement != null && successElement == null) {
      // Display error to user
      String error = errorElement.innerHtml;
      error = error.replaceAll("<h2>", "").replaceAll("</h2>", "").trim();

      return LoginResult(LoginResultType.LOGIN_FAIL, error);
    } else if (successElement != null && errorElement == null) {
      return LoginResult(LoginResultType.LOGIN_SUCCESS);
    } else {
      return LoginResult(LoginResultType.UNKNOWN_ERROR);
    }
  }
}
