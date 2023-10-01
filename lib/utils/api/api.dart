import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';

import '../../keys/string_key.dart';
import '../../models/courses/course.dart';
import '../../models/custom_exception.dart';
import '../../models/help/help_item.dart';
import '../../models/help/help_list.dart';
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

  Future<HelpList> getHelps() async {
    final response = await doRequest(http.get(
      Uri.parse(
          'https://raw.githubusercontent.com/Pyozer/UnivAgenda/dev/help/help_list.json'),
    ));

    return HelpList.fromJson(getData(response));
  }

  Future<String> getHelp(HelpItem helpItem) async {
    final response = await doRequest(http.get(helpItem.fileUrl));

    return getRawData(response);
  }
}
