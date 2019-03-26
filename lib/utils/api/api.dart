import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/ical/ical.dart';
import 'package:myagenda/utils/api/base_api.dart';
import 'package:myagenda/utils/ical_api.dart';

class Api extends BaseApi {
  Api() : super();

  Future<List<Course>> getCourses(String icalUrl) async {
    final response = await doRequest(http.get(
      "https://ical-to-json.herokuapp.com/convert.json?url=" +
          Uri.encodeComponent(icalUrl),
    ));
    
    return IcalAPI.icalToCourses(Ical.fromJson(getData(response)));
  }
}
