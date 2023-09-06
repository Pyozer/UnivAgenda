import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';

import '../../models/courses/course.dart';
import '../../models/help_item.dart';
import 'base_api.dart';
import '../ical_api.dart';
import '../translations.dart';
import '../../models/custom_exception.dart';

class Api extends BaseApi {
  Api() : super();

  Future<List<Course>> getCoursesCustomIcal(String icalUrl) async {
    final response = await doRequest(http.get(Uri.parse(icalUrl)));

    if (response.statusCode != 200 || response.body.isEmpty) {
      throw CustomException(
        'error',
        "Erreur lors de la récupération des cours. Veuillez vérifier l'url utilisée ou contactez nous.",
      );
    }

    try {
      final iCalendar = ICalendar.fromString(response.body);
      return IcalAPI.icalToCourses(iCalendar);
    } on ICalendarFormatException catch (e) {
      // TODO: Add translation
      throw CustomException(
        'error',
        'Le format reçu est incorrect.\n\nErreur:\n${e.msg}',
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
