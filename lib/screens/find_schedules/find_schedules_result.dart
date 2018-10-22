import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/ical_model.dart';
import 'package:myagenda/models/room.dart';
import 'package:myagenda/models/room_result.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/ical_api.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/no_result.dart';

class FindSchedulesResults extends StatefulWidget {
  final List<Room> searchResources;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const FindSchedulesResults({
    Key key,
    this.searchResources,
    this.startTime,
    this.endTime,
  }) : super(key: key);

  FindSchedulesResultsState createState() => FindSchedulesResultsState();
}

class FindSchedulesResultsState extends BaseState<FindSchedulesResults> {
  List<RoomResult> _searchResult;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _search();
  }

  void _search() async {
    // All rooms available between times defined
    List<RoomResult> results = [];

    if (widget.searchResources.length == 0) {
      if (mounted) {
        setState(() {
          _searchResult = results;
          _isLoading = false;
        });
      }
      return;
    }

    // Get actual datetime
    final date = DateTime.now();

    // Create DateTime from today with chosen hours
    DateTime dateTimeStart = DateTime(date.year, date.month, date.day,
        widget.startTime.hour, widget.startTime.minute);
    DateTime dateTimeEnd = DateTime(date.year, date.month, date.day,
        widget.endTime.hour, widget.endTime.minute);

    // Check data
    if (dateTimeEnd.isBefore(dateTimeStart)) {
      DialogPredefined.showEndTimeError(context);
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Check for every rooms if available
    for (final room in widget.searchResources) {
      String url =
          IcalAPI.prepareURL(prefs.university.agendaUrl, room.resourceId, 0);

      // Get data
      final response = await HttpRequest.get(url);

      if (!response.isSuccess) {
        if (mounted) {
          setState(() {
            _searchResult = [];
            _isLoading = false;
          });
        }

        final errorMsg = translations.get(StringKey.NETWORK_ERROR);
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
        return;
      }
      String icalStr = utf8.decode(response.httpResponse.bodyBytes);

      List<Course> listCourses = [];

      // Parse string ical to object
      List<IcalModel> icalModels = Ical.parseToIcal(icalStr);
      if (icalModels == null) {
        DialogPredefined.showICSFormatError(context);
        return;
      }

      for (final icalModel in icalModels) {
        // Transform IcalModel to Course
        // Add course to list
        listCourses.add(Course.fromIcalModel(icalModel));
      }

      // Sort list by date start
      listCourses.sort((a, b) => a.dateStart.compareTo(b.dateStart));

      // Delete all courses outside chosen hours
      DateTime startNoCourse;
      DateTime endNoCourse;

      listCourses.removeWhere((course) {
        bool isBeforeHours = course.dateEnd.isBefore(dateTimeStart) ||
            course.dateEnd == dateTimeStart;
        bool isAfterHours = course.dateStart.isAfter(dateTimeEnd) ||
            course.dateStart == dateTimeEnd;

        if (isBeforeHours &&
            (startNoCourse == null || course.dateEnd.isAfter(startNoCourse)))
          startNoCourse = course.dateEnd;
        if (isAfterHours && endNoCourse == null) endNoCourse = course.dateStart;

        return isBeforeHours || isAfterHours;
      });

      // If no course during chosen hours, mean that room is available
      if (listCourses.length == 0) {
        results.add(RoomResult(room, startNoCourse, endNoCourse));
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
        return ResultCard(
          roomResult: _searchResult[index],
        );
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
        title: translations.get(StringKey.FINDROOM_NORESULT),
        text: translations.get(StringKey.FINDROOM_NORESULT_TEXT),
      );
    else
      widget = _buildListResults();

    return AppbarPage(
      title: translations.get(StringKey.FINDROOM_RESULTS),
      body: widget,
    );
  }
}

class ResultCard extends StatelessWidget {
  final RoomResult roomResult;

  const ResultCard({Key key, this.roomResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translation = Translations.of(context);
    final locale = translation.locale;

    String info = '';
    if (roomResult.startAvailable != null) {
      info = "${translation.get(StringKey.FINDROOM_FROM)} ";
      info += Date.extractTimeWithDate(roomResult.startAvailable, locale);
    }

    if (roomResult.endAvailable != null) {
      info += " ${translation.get(StringKey.FINDROOM_TO)} ";
      info += Date.extractTimeWithDate(roomResult.endAvailable, locale);
    }

    final text = (info.length > 0)
        ? capitalize(info.trim())
        : translation.get(StringKey.FINDROOM_AVAILABLE);

    return Card(
      elevation: 3.0,
      child: ListTile(
        title: Text(roomResult.room.name),
        subtitle: Text(text),
      ),
    );
  }
}