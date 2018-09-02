import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/data.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/room_result.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/IcalAPI.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/circular_loader.dart';
import 'package:myagenda/widgets/ui/end_time_error.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';
import 'package:http/http.dart' as http;

class FindRoomScreen extends StatefulWidget {
  @override
  _FindRoomScreenState createState() => _FindRoomScreenState();
}

class _FindRoomScreenState extends State<FindRoomScreen> {
  bool isDataLoaded = false;
  bool isLoading = false;

  List<String> _campus = [];
  List<String> _departments = [];
  List<RoomResult> _searchResult = [];

  String _selectedCampus;
  String _selectedDepartment;
  TimeOfDay _selectedStartTime;
  TimeOfDay _selectedEndTime;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    // Init start/end time
    _selectedStartTime = TimeOfDay.now();
    _selectedEndTime = Date.addTimeToTime(_selectedStartTime, 1);

    // Get list of all campus
    _campus = Data.getAllCampus();

    // Define preselected campus depends on preferences
    final prefCampus = await Preferences.getCampus();
    _selectedCampus = _campus.contains(prefCampus) ? prefCampus : _campus[0];

    await _initDepartmentValue();

    setState(() {
      isDataLoaded = true;
    });
  }

  Future<Null> _initDepartmentValue() async {
    // Get list of all department of selected campus
    _departments = Data.getCampusDepartments(_selectedCampus);

    // Define preselected department depends on preferences
    final prefDepart = await Preferences.getDepartment();
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
          child: InkWell(
            onTap: () {},
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  value: value,
                  items: items.map((String value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
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

  Future<String> _fetchData(String url) async {
    final response = await http.get(url);

    return (response.statusCode == 200) ? response.body : null;
  }

  void _onSearch() async {
    // Get actual datetime
    final date = DateTime.now();

    // Create DateTime from today with chosen hours
    DateTime dateTimeStart = DateTime(date.year, date.month, date.day,
        _selectedStartTime.hour, _selectedStartTime.minute);
    DateTime dateTimeEnd = DateTime(date.year, date.month, date.day,
        _selectedEndTime.hour, _selectedEndTime.minute);

    // Check data
    if (dateTimeEnd.isBefore(dateTimeStart)) {
      DialogPredefined.showEndTimeError(context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    // All rooms available between times defined
    List<RoomResult> results = [];

    // Get all room in the department in the campus
    final rooms =
        Data.getGroups(_selectedCampus, _selectedDepartment, "Salles");

    // Check for every rooms if available
    for (final room in rooms) {
      String url = IcalAPI.prepareURL(
          _selectedCampus, _selectedDepartment, "Salles", room, 1);
      String icalStr = await _fetchData(url);

      List<Course> listCourses = [];

      // Parse string ical to object
      for (final icalModel in Ical.parseToIcal(icalStr)) {
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
        bool isBeforeHours = course.dateEnd.isBefore(dateTimeStart);
        bool isAfterHours = course.dateStart.isAfter(dateTimeEnd);

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

    setState(() {
      _searchResult = results;
      isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return AppbarPage(
      title: translations.get(StringKey.FINDROOM),
      body: Container(
          padding: const EdgeInsets.all(16.0),
          child: isDataLoaded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildDropdown(
                              translations.get(StringKey.CAMPUS),
                              _campus,
                              _selectedCampus, (String campus) {
                            setState(() {
                              _selectedCampus = campus;
                              _initDepartmentValue();
                            });
                          }),
                          flex: 4,
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0)),
                        Expanded(
                          child: _buildDropdown(
                              translations.get(StringKey.DEPARTMENT),
                              _departments,
                              _selectedDepartment, (String department) {
                            setState(() {
                              _selectedDepartment = department;
                            });
                          }),
                          flex: 6,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        _buildTimePart(
                            translations.get(StringKey.START_TIME_EVENT),
                            _selectedStartTime, (newStartTime) {
                          _onTimeChange(newStartTime, _selectedEndTime);
                        }),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0)),
                        _buildTimePart(
                            translations.get(StringKey.END_TIME_EVENT),
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
                        child: isLoading
                            ? Center(child: CircularLoader())
                            : ListView.builder(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                itemCount: _searchResult.length,
                                itemBuilder: (context, index) {
                                  return ResultCard(
                                    roomResult: _searchResult[index],
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                )
              : Container()),
    );
  }
}

class ResultCard extends StatelessWidget {
  final RoomResult roomResult;

  const ResultCard({Key key, this.roomResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = Translations.of(context).locale;

    String info = '';
    if (roomResult.startAvailable != null)
      info = Date.extractTimeWithDate(roomResult.startAvailable, locale);

    if (roomResult.endAvailable != null)
      info += " jusqu'à " +
          Date.extractTimeWithDate(roomResult.endAvailable, locale);

    return Card(
      elevation: 3.0,
      child: ListTile(
        title: Text(roomResult.room),
        subtitle:
            Text(info.length > 0 ? capitalize(info.trim()) : 'Disponible'),
      ),
    );
  }
}
