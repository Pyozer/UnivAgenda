import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';

import '../../keys/string_key.dart';
import '../../models/courses/course.dart';
import '../../models/custom_exception.dart';
import '../../models/help_item.dart';
import '../ical_api.dart';
import '../translations.dart';
import 'base_api.dart';

class Api extends BaseApi {
  Api() : super();

  Future<List<Course>> getCoursesCustomIcal(String icalUrl) async {
    final response = await doRequest(http.get(Uri.parse(icalUrl)));

    if (response.statusCode != 200 || response.body.isEmpty) {
      throw CustomException('error', i18n.text(StrKey.ERROR_BAD_URL));
    }

    try {
      final iCalendar = ICalendar.fromString(response.body);
      return IcalAPI.icalToCourses(iCalendar);
    } on ICalendarFormatException catch (e) {
      throw CustomException(
        'error',
        i18n.text(StrKey.ERROR_ICS_PARSE, {'errorMsg': e.msg}),
      );
    }
  }

  Future<List<HelpItem>> getHelps() async {
    final response = await doRequest(http.get(
      getAPIUrl('/helps'),
      headers: {HttpHeaders.acceptLanguageHeader: i18n.currentLanguage},
    ));

    return List<HelpItem>.from(getData(response).map(
      (x) => HelpItem.fromJson(x),
    ));
  }

  Future<String> getHelp(String filename) async {
    final response = await doRequest(http.get(
      getAPIUrl('/helps/$filename'),
      headers: {HttpHeaders.acceptLanguageHeader: i18n.currentLanguage},
    ));

    return getData<String>(response);
  }
}
