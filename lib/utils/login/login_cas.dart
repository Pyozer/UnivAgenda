import 'dart:async';
import 'package:html/parser.dart' show parse;
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/login/login_base.dart';

class LoginCAS extends LoginProcess {
  LoginCAS(loginUrl, username, password) : super(loginUrl, username, password);

  Future<LoginResult> login() async {
    final response = await HttpRequest.get(loginUrl);

    if (!response.isSuccess) return LoginResult(LoginResultType.NETWORK_ERROR);

    final document = parse(response.httpResponse.body);

    // Extract lt value from HTML
    final ltInput = document.querySelector('input[name="lt"]');
    String lt = "";
    if (ltInput?.attributes?.containsKey("value") ?? false)
      lt = ltInput.attributes['value'];

    final executionInput = document.querySelector('input[name="execution"]');
    String execution;
    if (executionInput?.attributes?.containsKey("value") ?? false)
      execution = executionInput.attributes['value'];

    // POST data
    Map<String, String> postParams = {
      "_eventId": "submit",
      "lt": lt,
      "submit": "LOGIN",
      "username": username,
      "password": password,
    };
    if (execution != null) postParams['execution'] = execution;

    // Get JSESSIONID from previous request header
    final cookie = response.httpResponse.headers["set-cookie"];

    // Second request, with all necessary data
    final loginResponse = await HttpRequest.post(
      loginUrl,
      body: postParams,
      headers: {"cookie": cookie},
    );

    if (!loginResponse.isSuccess)
      return LoginResult(LoginResultType.NETWORK_ERROR);

    final loginDocument = parse(loginResponse.httpResponse.body);
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
