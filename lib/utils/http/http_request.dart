import 'dart:async';

import 'package:http/http.dart' as http;

const successHTTPCode = [200, 304, 401];

class HttpResult {
  final bool isSuccess;
  final http.Response? httpResponse;

  HttpResult(this.isSuccess, [this.httpResponse]);

  factory HttpResult.success(http.Response response) =>
      HttpResult(true, response);
  factory HttpResult.fail() => HttpResult(false);
}

class HttpRequest {
  static Future<HttpResult> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    http.Response response;

    try {
      response = await http.get(Uri.parse(url), headers: headers);
    } catch (_) {
      return HttpResult.fail();
    }

    if (!successHTTPCode.contains(response.statusCode)) {
      return HttpResult.fail();
    }

    return HttpResult.success(response);
  }
}
