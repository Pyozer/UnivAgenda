import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/room_result.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';

class FindRoomScreen extends StatefulWidget {
  @override
  _FindRoomScreenState createState() => _FindRoomScreenState();
}

class _FindRoomScreenState extends State<FindRoomScreen> {
  List<String> _departments = [];
  List<RoomResult> _searchResult = [];

  String _selectedDepartment;
  TimeOfDay _selectedStartTime;
  TimeOfDay _selectedEndTime;

  @override
  void initState() {
    super.initState();

    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime = Date.addTimeToTime(_selectedStartTime, 1);

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

  void _onTimeChange(TimeOfDay startTime, TimeOfDay endTime) {
    if (startTime != null && endTime != null)
      setState(() {
        _selectedStartTime = startTime;
        _selectedEndTime = endTime;
      });
  }

  void _onSearch() {
    List<RoomResult> results = List.generate(10, (index) {
      return RoomResult("Salle $index", DateTime.now(), DateTime.now());
    });

    setState(() {
      _searchResult = results;
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

  List<DropdownMenuItem<String>> _dropdownListDepartments() {
    return _departments.map((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value));
    }).toList();
  }

  Future<TimeOfDay> _openTimePicker(TimeOfDay time) async {
    return await showTimePicker(context: context, initialTime: time);
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
            _buildHeader(translations.get(StringKey.DEPARTMENT)),
            Card(
              elevation: 3.0,
              margin: const EdgeInsets.only(top: 8.0, bottom: 24.0),
              child: InkWell(
                onTap: () {},
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                _buildTimePart(translations.get(StringKey.START_TIME_EVENT),
                    _selectedStartTime, (newStartTime) {
                  _onTimeChange(newStartTime, _selectedEndTime);
                }),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0)),
                _buildTimePart(translations.get(StringKey.END_TIME_EVENT),
                    _selectedEndTime, (newEndTime) {
                  _onTimeChange(_selectedStartTime, newEndTime);
                }),
              ],
            ),
            RaisedButtonColored(
              onPressed: _onSearch,
              text: "SEARCH",
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: _searchResult.length,
                  itemBuilder: (context, index) {
                    return ResultCard(
                      roomResult: _searchResult[index],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final RoomResult roomResult;

  const ResultCard({Key key, this.roomResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = Translations.of(context).locale;
    final dateStart =
        Date.extractTimeWithDate(roomResult.startAvailable, locale);
    final dateEnd = Date.extractTimeWithDate(roomResult.endAvailable, locale);

    return Card(
      elevation: 3.0,
      child: ListTile(
        title: Text(roomResult.room),
        subtitle: Text('De ' + dateStart + ' à ' + dateEnd),
      ),
    );
  }
}
