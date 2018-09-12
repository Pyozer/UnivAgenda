import 'dart:async';

enum LoginResultType { LOGIN_SUCCESS, LOGIN_FAIL, NETWORK_ERROR, UNKNOWN_ERROR }

class LoginResult {
  final LoginResultType result;
  final String message;

  LoginResult(this.result, [this.message = ""]);
}

abstract class LoginProcess {
  final String loginUrl;
  final String username;
  final String password;

  LoginProcess(this.loginUrl, this.username, this.password);

  Future<LoginResult> login();
}
