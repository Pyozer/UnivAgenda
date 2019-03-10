import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/findschedules_result.dart';
import 'package:myagenda/models/resource.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/ical_api.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/screen_message/no_result.dart';

class FindSchedulesResults extends StatefulWidget {
  final List<Resource> searchResources;
  final DateTime startTime;
  final DateTime endTime;

  const FindSchedulesResults({
    Key key,
    this.searchResources,
    this.startTime,
    this.endTime,
  }) : super(key: key);

  FindSchedulesResultsState createState() => FindSchedulesResultsState();
}

class FindSchedulesResultsState extends BaseState<FindSchedulesResults> {
  List<FindSchedulesResult> _searchResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      _search();
    });
  }

  void _search() async {
    // All rooms available between times defined
    List<FindSchedulesResult> results = [];

    if (widget.searchResources.length == 0) {
      if (mounted) {
        setState(() {
          _searchResult = results;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    // Check for every rooms if available
    for (final room in widget.searchResources) {
      String url =
          IcalAPI.prepareURL(prefs.university.agendaUrl, room.resourceId, 0, 0);

      // Get data
      final response = await HttpRequest.get(url);

      if (!response.isSuccess) {
        if (mounted) {
          setState(() {
            _searchResult = [];
            _isLoading = false;
          });
        }

        DialogPredefined.showSimpleMessage(
          context,
          i18n.text(StrKey.ERROR),
          i18n.text(StrKey.NETWORK_ERROR),
        );
        return;
      }
      String icalStr = utf8.decode(response.httpResponse.bodyBytes);

      // Parse string ical to object
      List<Course> listCourses = await Ical(icalStr).parseToIcal();
      if (listCourses == null) {
        DialogPredefined.showICSFormatError(context);
        return;
      }

      // Sort list by date start
      listCourses.sort((a, b) => a.dateStart.compareTo(b.dateStart));

      // Delete all courses outside chosen hours
      DateTime startNoCourse;
      DateTime endNoCourse;

      listCourses.removeWhere((course) {
        bool isBeforeHours = course.dateEnd.isBefore(widget.startTime) ||
            course.dateEnd == widget.startTime;
        bool isAfterHours = course.dateStart.isAfter(widget.endTime) ||
            course.dateStart == widget.endTime;

        if (isBeforeHours &&
            (startNoCourse == null || course.dateEnd.isAfter(startNoCourse)))
          startNoCourse = course.dateEnd;
        if (isAfterHours && endNoCourse == null) endNoCourse = course.dateStart;

        return isBeforeHours || isAfterHours;
      });

      // If no course during chosen hours, mean that room is available
      if (listCourses.length == 0) {
        results.add(FindSchedulesResult(room, startNoCourse, endNoCourse));
      }
    }

    if (mounted) {
      setState(() {
        _searchResult = results;
        _isLoading = false;
      });
    }
  }

  Widget _buildListResults() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      itemCount: _searchResult.length,
      itemBuilder: (context, index) {
        return ResultCard(findResult: _searchResult[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (_isLoading)
      widget = const Center(child: const CircularProgressIndicator());
    else if (_searchResult.length == 0)
      widget = NoResult(
        title: i18n.text(StrKey.FINDSCHEDULES_NORESULT),
        text: i18n.text(StrKey.FINDSCHEDULES_NORESULT_TEXT),
      );
    else
      widget = _buildListResults();

    return AppbarPage(
      title: i18n.text(StrKey.FINDSCHEDULES_RESULTS),
      body: widget,
    );
  }
}

class ResultCard extends StatelessWidget {
  final FindSchedulesResult findResult;

  const ResultCard({Key key, this.findResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String info = '';
    if (findResult.startAvailable != null) {
      info = "${i18n.text(StrKey.FINDSCHEDULES_FROM)} ";
      info += Date.extractTimeWithDate(findResult.startAvailable);
    }

    if (findResult.endAvailable != null) {
      info += " ${i18n.text(StrKey.FINDSCHEDULES_TO)} ";
      info += Date.extractTimeWithDate(findResult.endAvailable);
    }

    final text = (info.length > 0)
        ? capitalize(info.trim())
        : i18n.text(StrKey.FINDSCHEDULES_AVAILABLE);

    return Card(
      elevation: 3.0,
      child: ListTile(
        title: Text(findResult.resource.name),
        subtitle: Text(text),
      ),
    );
  }
}
