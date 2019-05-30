import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/base_response.dart';
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

  Map<String, dynamic> getData<T>(http.Response response) {
    CustomException error;
    try {
      final res = BaseResponse.fromJson(json.decode(response.body));
      if (res.error == null) return res.data;
      error = CustomException("error", res.error);
    } catch (e) {
      error = CustomException("error", i18n.text(StrKey.ERROR_JSON_PARSE));
    }
    throw error ?? CustomException("unknown", i18n.text(StrKey.UNKNOWN_ERROR));
  }
}
