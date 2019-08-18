import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/screens/find_schedules/find_schedules_select.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/dropdown.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class FindSchedulesScreen extends StatefulWidget {
  @override
  _FindSchedulesScreenState createState() => _FindSchedulesScreenState();
}

class _FindSchedulesScreenState extends BaseState<FindSchedulesScreen> {
  List<String> _roomKeys = [];

  TimeOfDay _startTime;
  TimeOfDay _endTime;

  bool _alreadyLoaded = false;

  @override
  void initState() {
    super.initState();
    AnalyticsProvider.setScreen(widget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_alreadyLoaded) _initData();
  }

  void _initData() {
    // Init start/end time
    _startTime = TimeOfDay(hour: 13, minute: 30);
    _endTime = TimeOfDay(hour: 15, minute: 0);

    _roomKeys = prefs.checkDataValues(["Rooms"]); // Find a room by default
    _alreadyLoaded = true;
  }

  Widget _buildDropdown(String title, List<String> items, String value,
      ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(title),
        Card(
          elevation: 3.0,
          margin: const EdgeInsets.only(top: 8.0, bottom: 24.0),
          child: Dropdown(
            items: items,
            value: value,
            onChanged: onChanged,
          ),
        )
      ],
    );
  }

  void _onTimeChange(TimeOfDay startTime, TimeOfDay endTime) {
    if (startTime != null && endTime != null)
      setState(() {
        _startTime = startTime;
        _endTime = endTime;
      });
  }

  Text _buildHeader(String text) {
    return Text(text, style: theme.textTheme.subhead);
  }

  Widget _buildTimePicker(TimeOfDay time, ValueChanged<TimeOfDay> onChange) {
    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.only(top: 8.0, bottom: 24.0),
      child: InkWell(
        onTap: () {
          _openTimePicker(time).then((newTime) {
            onChange(newTime);
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(time.format(context)),
        ),
      ),
    );
  }

  Widget _buildTimePart(
      String title, TimeOfDay time, ValueChanged<TimeOfDay> onChange) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(title),
          _buildTimePicker(time, onChange),
        ],
      ),
    );
  }

  Future<TimeOfDay> _openTimePicker(TimeOfDay time) async {
    return await showTimePicker(context: context, initialTime: time);
  }

  void _onSearchPressed() {
    // Get actual datetime
    final date = DateTime.now();

    // Create DateTime from today with chosen hours
    var startTime = Date.changeTime(date, _startTime.hour, _startTime.minute);
    var endTime = Date.changeTime(date, _endTime.hour, _endTime.minute);

    // Check data
    if (endTime.isBefore(startTime)) {
      DialogPredefined.showEndTimeError(context);
      return;
    }

    Navigator.of(context).push(
      CustomRoute(
        builder: (context) => FindSchedulesFilter(
          groupKeySearch: _roomKeys,
          startTime: startTime,
          endTime: endTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dropdownChoices = [];

    List<List<String>> allGroupKeys = prefs.getAllGroupKeys(_roomKeys);
    for (var level = 0; level < 2; level++) {
      final menuTitle = level == 0
          ? i18n.text(StrKey.FINDSCHEDULES_SEARCH_ORIGIN)
          : i18n.text(StrKey.FINDSCHEDULES_FILTER);

      dropdownChoices.add(
        _buildDropdown(
          menuTitle,
          allGroupKeys[level],
          _roomKeys[level],
          (String newKey) {
            setState(() {
              _roomKeys[level] = newKey;
              _roomKeys = prefs.checkDataValues(_roomKeys);
            });
          },
        ),
      );
    }

    return AppbarPage(
      title: i18n.text(StrKey.FINDSCHEDULES),
      fab: FloatingActionButton.extended(
        heroTag: "fabBtn",
        icon: Icon(OMIcons.search),
        label: Text(i18n.text(StrKey.SEARCH)),
        onPressed: _onSearchPressed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: []
            ..addAll(dropdownChoices)
            ..addAll([
              Row(
                children: [
                  _buildTimePart(
                    i18n.text(StrKey.START_TIME_EVENT),
                    _startTime,
                    (startTime) => _onTimeChange(startTime, _endTime),
                  ),
                  const SizedBox(width: 32.0),
                  _buildTimePart(
                    i18n.text(StrKey.END_TIME_EVENT),
                    _endTime,
                    (endTime) => _onTimeChange(_startTime, endTime),
                  ),
                ],
              ),
            ]),
        ),
      ),
    );
  }
}
