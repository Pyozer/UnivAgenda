import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/findroom/findroom_result.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/dropdown.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';

class FindRoomScreen extends StatefulWidget {
  @override
  _FindRoomScreenState createState() => _FindRoomScreenState();
}

class _FindRoomScreenState extends State<FindRoomScreen> {
  List<String> _campus = [];
  List<String> _departments = [];

  String _selectedCampus;
  String _selectedDepartment;
  TimeOfDay _selectedStartTime;
  TimeOfDay _selectedEndTime;

  bool _alreadyLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_alreadyLoaded) _initData();
  }

  void _initData() {
    final prefs = PreferencesProvider.of(context);
    // Init start/end time
    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime = Date.addTimeToTime(_selectedStartTime, 1);
    // Get list of all campus
    _campus = prefs.getAllCampus(prefs.university);
    // Define preselected campus depends on preferences
    final prefCampus = prefs.campus;
    _selectedCampus = _campus.contains(prefCampus) ? prefCampus : _campus[0];

    _initDepartmentValue();

    _alreadyLoaded = true;
  }

  void _initDepartmentValue() {
    final prefs = PreferencesProvider.of(context);
    // Get list of all department of selected campus
    _departments =
        prefs.getCampusDepartments(prefs.university, _selectedCampus);
    // Define preselected department depends on preferences
    final prefDepart = prefs.department;
    _selectedDepartment =
        _departments.contains(prefDepart) ? prefDepart : _departments[0];
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
    return Text(text, style: Theme.of(context).textTheme.subhead);
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
        builder: (context) => FindRoomResults(
              campus: _selectedCampus,
              department: _selectedDepartment,
              startTime: _selectedStartTime,
              endTime: _selectedEndTime,
            ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return AppbarPage(
      title: translations.get(StringKey.FINDROOM),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdown(
              translations.get(StringKey.CAMPUS),
              _campus,
              _selectedCampus,
              (String campus) {
                setState(() {
                  _selectedCampus = campus;
                  _initDepartmentValue();
                });
              },
            ),
            _buildDropdown(
              translations.get(StringKey.DEPARTMENT),
              _departments,
              _selectedDepartment,
              (String department) {
                setState(() {
                  _selectedDepartment = department;
                });
              },
            ),
            Row(
              children: <Widget>[
                _buildTimePart(
                  translations.get(StringKey.START_TIME_EVENT),
                  _selectedStartTime,
                  (newStartTime) {
                    _onTimeChange(newStartTime, _selectedEndTime);
                  },
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0)),
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
          ],
        ),
      ),
    );
  }
}
