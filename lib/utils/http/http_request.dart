import 'dart:async';
import 'package:http/http.dart' as http;

class HttpResult {
  final bool isSuccess;
  final http.Response httpResponse;

  HttpResult(this.isSuccess, [this.httpResponse]);

  factory HttpResult.success(http.Response response) =>
      HttpResult(true, response);
  factory HttpResult.fail() => HttpResult(false);
}

class HttpRequest {
  static Future<HttpResult> get(String url, {Map<String, String> headers}) async {
    http.Response response;

    try {
      response = await http.get(url, headers: headers);
    } catch (_) {
      return HttpResult.fail();
    }

    if (response.statusCode != 200) return HttpResult.fail();

    return HttpResult.success(response);
  }

  static Future<HttpResult> post(String url, {body, Map<String, String> headers}) async {
    http.Response response;

    try {
      response = await http.post(url, body: body, headers: headers);
    } catch (_) {
      return HttpResult.fail();
    }

    if (response.statusCode != 200) return HttpResult.fail();

    return HttpResult.success(response);
  }
}
