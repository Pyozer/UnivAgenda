import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/translations.dart';

class FindRoomScreen extends StatefulWidget {
  @override
  _FindRoomScreenState createState() => _FindRoomScreenState();
}

class _FindRoomScreenState extends State<FindRoomScreen> {
  List<String> _departments = [];

  String _selectedDepartment;
  TimeOfDay _selectedStartTime;
  TimeOfDay _selectedEndTime;

  @override
  void initState() {
    super.initState();

    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime =
        Date.addDurationToTime(_selectedStartTime, const Duration(hours: 1));

    _departments = [];
    Data.getAllCampus().forEach((campus) {
      _departments.addAll(Data.getCampusDepartments(campus));
    });
    _selectedDepartment = _departments[0];
  }

  void _onBuildingChange(String department) {
    setState(() {
      _selectedDepartment = department;
    });
  }

  void _onStartTimeChange(TimeOfDay startTime) {
    setState(() {
      _selectedStartTime = startTime;
    });
  }

  void _onEndTimeChange(TimeOfDay endTime) {
    setState(() {
      _selectedEndTime = endTime;
    });
  }

  Text _buildHeader(String text) {
    return Text(text, style: Theme.of(context).textTheme.subhead);
  }

  List<DropdownMenuItem<String>> _dropdownListDepartments() {
    return _departments.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  Future<TimeOfDay> _openTimePicker(TimeOfDay time) async {
    return await showTimePicker(
      context: context,
      initialTime: time,
    );
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    final startTimeStr = '${_selectedStartTime.hour}:${_selectedStartTime
        .minute}';
    final endTimeStr = '${_selectedEndTime.hour}:${_selectedEndTime.minute}';

    return AppbarPage(
      title: translations.get(StringKey.FINDROOM),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(translations.get(StringKey.DEPARTMENT)),
            Card(
              margin: const EdgeInsets.only(top: 12.0, bottom: 24.0),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton(
                    value: _selectedDepartment,
                    items: _dropdownListDepartments(),
                    onChanged: _onBuildingChange,
                  ),
                ),
              ),
            ),
            _buildHeader(translations.get(StringKey.START_TIME_EVENT)),
            Card(
              margin: const EdgeInsets.only(top: 12.0, bottom: 24.0),
              child: InkWell(
                onTap: () {
                  _openTimePicker(_selectedStartTime).then(_onStartTimeChange);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(startTimeStr),
                ),
              ),
            ),
            _buildHeader(translations.get(StringKey.END_TIME_EVENT)),
            Card(
              margin: const EdgeInsets.only(top: 12.0, bottom: 24.0),
              child: InkWell(
                onTap: () {
                  _openTimePicker(_selectedEndTime).then(_onEndTimeChange);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(endTimeStr),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
