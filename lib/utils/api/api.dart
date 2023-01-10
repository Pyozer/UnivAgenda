import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/models/help_item.dart';
import 'package:univagenda/utils/api/base_api.dart';
import 'package:univagenda/utils/ical_api.dart';
import 'package:univagenda/utils/translations.dart';

import '../../models/custom_exception.dart';

class Api extends BaseApi {
  Api() : super();

  Future<List<Course>> getCoursesCustomIcal(String icalUrl) async {
    final response = await doRequest(http.get(Uri.parse(icalUrl)));
    // i18n.currentLanguage

    if (response.statusCode != 200 || response.body.isEmpty) {
      throw CustomException(
        "error",
        "Erreur lors de la récupération des cours. Veuillez vérifier l'url utilisée ou contactez nous.",
      );
    }

    final iCalendar = ICalendar.fromString(response.body);
    return IcalAPI.icalToCourses(iCalendar);
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
