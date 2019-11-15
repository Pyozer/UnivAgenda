import 'dart:async';

import 'package:univagenda/models/preferences/university.dart';

enum LoginResultType { LOGIN_SUCCESS, LOGIN_FAIL, NETWORK_ERROR, UNKNOWN_ERROR }

class LoginResult {
  final LoginResultType result;
  final String message;

  LoginResult(this.result, [this.message = ""]);
}

abstract class LoginProcess {
  final University university;
  final String username;
  final String password;

  LoginProcess(this.university, this.username, this.password);

  Future<LoginResult> login();
}
