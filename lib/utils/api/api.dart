import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/help_item.dart';
import 'package:myagenda/models/ical/ical.dart';
import 'package:myagenda/utils/api/base_api.dart';
import 'package:myagenda/utils/ical_api.dart';
import 'package:myagenda/utils/translations.dart';

class Api extends BaseApi {
  Api() : super();

  Future<List<Course>> getCourses(String icalUrl) async {
    final response = await doRequest(http.get(
      getAPIUrl("/parseical", {'url': icalUrl}),
      headers: {HttpHeaders.acceptLanguageHeader: i18n.currentLanguage},
    ));

    return IcalAPI.icalToCourses(Ical.fromJson(getDataMap(response)));
  }

  Future<List<HelpItem>> getHelps() async {
    final response = await doRequest(http.get(
      getAPIUrl("/helps"),
      headers: {HttpHeaders.acceptLanguageHeader: i18n.currentLanguage},
    ));

    return List<HelpItem>.from(getData(response).map(
      (x) => HelpItem.fromJson(x),
    ));
  }

  Future<String> getHelp(String filename) async {
    final response = await doRequest(http.get(
      getAPIUrl("/helps/$filename"),
      headers: {HttpHeaders.acceptLanguageHeader: i18n.currentLanguage},
    ));

    return getData<String>(response);
  }
}
