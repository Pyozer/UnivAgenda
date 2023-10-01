import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../keys/string_key.dart';
import '../../models/custom_exception.dart';
import '../translations.dart';

abstract class BaseApi {
  BaseApi();

  Future<http.Response> doRequest(Future<http.Response> httpRequest) async {
    try {
      return await httpRequest;
    } catch (e) {
      throw CustomException(
        'error_server_response',
        i18n.text(StrKey.NETWORK_ERROR),
      );
    }
  }

  String getRawData(http.Response response) {
    if (response.statusCode != 200) {
      throw CustomException(
        'error_server_response',
        i18n.text(
          StrKey.API_RESPONSE_ERROR,
          {'statusCode': response.statusCode},
        ),
      );
    }

    return response.body;
  }

  dynamic getData(http.Response response) {
    final rawData = getRawData(response);

    try {
      return json.decode(rawData);
    } catch (e) {
      throw CustomException('error', i18n.text(StrKey.ERROR_JSON_PARSE));
    }
  }
}
