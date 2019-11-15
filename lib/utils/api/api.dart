import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/models/help_item.dart';
import 'package:univagenda/models/ical/ical.dart';
import 'package:univagenda/models/preferences/university.dart';
import 'package:univagenda/utils/api/base_api.dart';
import 'package:univagenda/utils/date.dart';
import 'package:univagenda/utils/ical_api.dart';
import 'package:univagenda/utils/translations.dart';

class Api extends BaseApi {
  Api() : super();

  Future<List<University>> getResources() async {
    final response = await doRequest(http.get(
      getAPIUrl("/resources"),
      headers: {HttpHeaders.acceptLanguageHeader: i18n.currentLanguage},
    ));

    return List<University>.from(getData(response).map(
      (x) => University.fromJson(x),
    ));
  }

  Future<Map<String, dynamic>> getUnivResources(String univId) async {
    final response = await doRequest(http.get(
      getAPIUrl('/resources/$univId'),
      headers: {HttpHeaders.acceptLanguageHeader: i18n.currentLanguage},
    ));

    return getDataMap(response);
  }

  Future<List<Course>> getCourses(
    String univId,
    int resId,
    IcalPrepareResult dates,
  ) async {
    final response = await doRequest(http.get(
      getAPIUrl("/parseIcal/$univId/$resId", {
        'firstDate': Date.formatDateApi(dates.firstDate),
        'lastDate': Date.formatDateApi(dates.lastDate),
      }),
      headers: {HttpHeaders.acceptLanguageHeader: i18n.currentLanguage},
    ));

    return IcalAPI.icalToCourses(Ical.fromJson(getDataMap(response)));
  }

  Future<List<Course>> getCoursesCustomIcal(String icalUrl) async {
    final response = await doRequest(http.get(
      getAPIUrl("/parseCustomIcal", {'url': icalUrl}),
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
