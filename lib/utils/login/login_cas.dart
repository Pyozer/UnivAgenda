import 'dart:async';
import 'package:html/parser.dart' show parse;
import 'package:univagenda/models/preferences/university.dart';
import 'package:univagenda/utils/http/http_request.dart';
import 'package:univagenda/utils/login/login_base.dart';

class LoginCAS extends LoginProcess {
  LoginCAS(University university, String username, String password)
      : super(university, username, password);

  Future<LoginResult> login() async {
    final response = await HttpRequest.get(university.loginUrl);

    if (!response.isSuccess) return LoginResult(LoginResultType.NETWORK_ERROR);

    final document = parse(response.httpResponse.body);

    // POST data
    Map<String, String> postParams = {};
    postParams[university.credentialFields.username] = username;
    postParams[university.credentialFields.password] = password;

    // Extract fields value from HTML
    university.loginFields.forEach((field) {
      final fieldElem = document.querySelector('input[name="' + field + '"]');
      String fieldValue = "";
      if (fieldElem?.attributes?.containsKey('value') ?? false)
        fieldValue = fieldElem.attributes['value'];
      postParams[field] = fieldValue;
    });

    // Get JSESSIONID from previous request header
    final cookie = response.httpResponse.headers["set-cookie"];

    // Second request, with all necessary data
    final loginResponse = await HttpRequest.post(
      university.loginUrl,
      body: postParams,
      headers: {"cookie": cookie},
    );

    if (!loginResponse.isSuccess)
      return LoginResult(LoginResultType.NETWORK_ERROR);

    final loginDocument = parse(loginResponse.httpResponse.body);
    final errorElement = loginDocument.querySelector(
      university.statusTags.error,
    );
    final successElement = loginDocument.querySelector(
      university.statusTags.success,
    );

    if (errorElement != null) {
      // Display error to user
      return LoginResult(LoginResultType.LOGIN_FAIL, errorElement.innerHtml);
    } else if (successElement != null) {
      return LoginResult(LoginResultType.LOGIN_SUCCESS);
    } else {
      return LoginResult(LoginResultType.UNKNOWN_ERROR);
    }
  }
}
