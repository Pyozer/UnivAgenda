import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/custom_exception.dart';
import 'package:myagenda/utils/translations.dart';

abstract class BaseApi {
  BaseApi();

  Future<http.Response> doRequest(Future<http.Response> httpRequest) async {
    try {
      return await httpRequest;
    } catch (_) {
      throw CustomException(
        "error_server_response",
        i18n.text(StrKey.NETWORK_ERROR),
      );
    }
  }

  T parseData<T>(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300)
      return json.decode(response.body);
    if (response.statusCode >= 500)
      throw CustomException("server_error", i18n.text(StrKey.GET_RES_ERROR));
    throw CustomException("unknown", i18n.text(StrKey.UNKNOWN_ERROR));
  }

  Map<String, dynamic> getData(http.Response response) {
    return parseData<Map<String, dynamic>>(response);
  }
}
