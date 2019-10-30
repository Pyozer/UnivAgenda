import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/findschedules_result.dart';
import 'package:myagenda/models/resource.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/api/api.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/ical_api.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/screen_message/no_result.dart';

class Tuple {
  final Resource resource;
  final List<Course> courses;

  Tuple(this.resource, this.courses);
}

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

class FindSchedulesResultsState extends BaseState<FindSchedulesResults>
    with AfterLayoutMixin {
  List<FindSchedulesResult> _searchResult;
  bool _isLoading = true;

  @override
  void afterFirstLayout(BuildContext context) {
    _search();
    AnalyticsProvider.setScreen(widget);
  }

  void _search() async {
    if (!mounted) return;
    // All rooms available between times defined
    List<FindSchedulesResult> results = [];

    if (widget.searchResources.isEmpty) {
      setState(() {
        _searchResult = results;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final icalDates = IcalAPI.prepareIcalDates(0);

    List<Tuple> apiRequests = [];
    try {
      apiRequests = await Future.wait<Tuple>(
        widget.searchResources.map((resource) async {
          return Tuple(
            resource,
            await Api().getCourses(
              prefs.university.id,
              resource.resourceId,
              icalDates,
            ),
          );
        }),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchResult = [];
        _isLoading = false;
      });

      DialogPredefined.showSimpleMessage(
        context,
        i18n.text(StrKey.ERROR),
        i18n.text(StrKey.NETWORK_ERROR),
      );
      return;
    }

    // Check for every rooms if available
    for (final apiResult in apiRequests) {
      // Sort list by date start
      apiResult.courses.sort((a, b) => a.dateStart.compareTo(b.dateStart));

      // Store maxStart and minEnd to display hours of availables
      DateTime maxStartEmpty;
      DateTime minEndEmpty;

      // Delete all courses outside chosen hours
      apiResult.courses.where((course) {
        bool isBefore = course.dateStart.isBefore(widget.startTime) ||
            course.dateEnd == widget.startTime;
        bool isAfter = course.dateStart.isAfter(widget.endTime) ||
            course.dateStart == widget.endTime;

        if (isBefore && (maxStartEmpty == null || course.dateEnd.isAfter(maxStartEmpty)))
          maxStartEmpty = course.dateEnd;
        if (isAfter && minEndEmpty == null) minEndEmpty = course.dateStart;

        return isBefore || isAfter;
      });

      // If no course during chosen hours, mean that room is available
      if (apiResult.courses.isEmpty) {
        results.add(
          FindSchedulesResult(apiResult.resource, maxStartEmpty, minEndEmpty),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _searchResult = results;
      _isLoading = false;
    });
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

  Widget _buildBody() {
    if (_isLoading)
      return const Center(child: const CircularProgressIndicator());
    if (_searchResult.isEmpty)
      return NoResult(
        title: i18n.text(StrKey.FINDSCHEDULES_NORESULT),
        text: i18n.text(StrKey.FINDSCHEDULES_NORESULT_TEXT),
      );
    return _buildListResults();
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      title: i18n.text(StrKey.FINDSCHEDULES_RESULTS),
      body: _buildBody(),
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

    final text = (info.isNotEmpty)
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
