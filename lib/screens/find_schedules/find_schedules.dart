import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/screens/find_schedules/find_schedules_select.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/widgets/ui/dropdown.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';

class FindSchedulesScreen extends StatefulWidget {
  @override
  _FindSchedulesScreenState createState() => _FindSchedulesScreenState();
}

class _FindSchedulesScreenState extends BaseState<FindSchedulesScreen> {
  List<String> _roomKeys = [];

  TimeOfDay _selectedStartTime;
  TimeOfDay _selectedEndTime;

  bool _alreadyLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_alreadyLoaded) _initData();
  }

  void _initData() {
    // Init start/end time
    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime = Date.addTimeToTime(_selectedStartTime, 1);

    _roomKeys = prefs.checkDataValues(["Rooms"]); // Find a room by default

    _alreadyLoaded = true;
  }

  Widget _buildDropdown(String title, List<String> items, String value,
      ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
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
        _selectedStartTime = startTime;
        _selectedEndTime = endTime;
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
        children: <Widget>[
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
    Navigator.of(context).push(
      CustomRoute(
        builder: (context) => FindSchedulesFilter(
              groupKeySearch: _roomKeys,
              startTime: _selectedStartTime,
              endTime: _selectedEndTime,
            ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dropdownChoices = [];

    List<List<String>> allGroupKeys = prefs.getAllGroupKeys(_roomKeys);
    for (var level = 0; level < 2; level++) {
      dropdownChoices.add(
        _buildDropdown(
          level == 0 ? "Search origin" : "Filter $level",
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
      title: translations.get(StringKey.FINDSCHEDULES),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: []
            ..addAll(dropdownChoices)
            ..addAll([
              Row(
                children: <Widget>[
                  _buildTimePart(
                    translations.get(StringKey.START_TIME_EVENT),
                    _selectedStartTime,
                    (newStartTime) {
                      _onTimeChange(newStartTime, _selectedEndTime);
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0)),
                  _buildTimePart(
                    translations.get(StringKey.END_TIME_EVENT),
                    _selectedEndTime,
                    (newEndTime) {
                      _onTimeChange(_selectedStartTime, newEndTime);
                    },
                  ),
                ],
              ),
              RaisedButtonColored(
                onPressed: _onSearchPressed,
                text: translations.get(StringKey.SEARCH),
              ),
            ]),
        ),
      ),
    );
  }
}
