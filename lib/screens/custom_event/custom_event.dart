import 'package:flutter/material.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/models/courses/custom_course.dart';
import 'package:univagenda/models/courses/weekday.dart';
import 'package:univagenda/screens/appbar_screen.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/date.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/settings/list_tile_color.dart';
import 'package:univagenda/widgets/ui/circle_text.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:uuid/uuid.dart';

class CustomEventScreen extends StatefulWidget {
  final CustomCourse? course;

  const CustomEventScreen({Key? key, this.course}) : super(key: key);

  @override
  CustomEventScreenState createState() => CustomEventScreenState();
}

class CustomEventScreenState extends State<CustomEventScreen> {
  final _descNode = FocusNode();
  final _locationNode = FocusNode();

  bool _isAllDay = false;
  late TimeOfDay _prevStartTime;
  late TimeOfDay _prevEndTime;

  bool _isRecurrent = false;
  bool _isColor = false;
  late CustomCourse _customCourse;

  late CustomCourse _baseCourse;

  @override
  void initState() {
    super.initState();
    final initFirstDate = DateTime.now();
    final initEndDate = initFirstDate.add(const Duration(hours: 1));

    _baseCourse = CustomCourse.empty(initFirstDate, initEndDate);

    // Init view
    if (widget.course != null) {
      _customCourse = CustomCourse.copy(widget.course!);
      _isRecurrent = _customCourse.isRecurrentEvent();
      _isAllDay = _customCourse.isAllDay();
      _isColor = _customCourse.hasColor();
    } else {
      _customCourse = CustomCourse.empty(initFirstDate, initEndDate);
    }

    _prevStartTime = TimeOfDay.fromDateTime(_customCourse.dateStart);
    _prevEndTime = TimeOfDay.fromDateTime(_customCourse.dateEnd);
    AnalyticsProvider.setScreen(widget);
  }

  @override
  void dispose() {
    _descNode.dispose();
    _locationNode.dispose();
    super.dispose();
  }

  void _onRecurrentDate(bool value) {
    setState(() => _isRecurrent = value);
  }

  void _onAllDay(bool newIsAllDay) {
    if (!_isAllDay && newIsAllDay) {
      _prevStartTime = TimeOfDay.fromDateTime(_customCourse.dateStart);
      _prevEndTime = TimeOfDay.fromDateTime(_customCourse.dateEnd);

      _customCourse.dateStart = Date.changeTime(
        _customCourse.dateStart,
        hour: 0,
        minute: 0,
        second: 0,
      );
      _customCourse.dateEnd = Date.changeTime(
        _customCourse.dateEnd,
        hour: 23,
        minute: 59,
        second: 59,
      );
    } else if (_isAllDay && !newIsAllDay) {
      _customCourse.dateStart = Date.changeTime(
        _customCourse.dateStart,
        hour: _prevStartTime.hour,
        minute: _prevStartTime.minute,
      );
      _customCourse.dateEnd = Date.changeTime(
        _customCourse.dateEnd,
        hour: _prevEndTime.hour,
        minute: _prevEndTime.minute,
      );
    }
    setState(() => _isAllDay = newIsAllDay);
  }

  void _onColorCustom(bool value) {
    setState(() => _isColor = value);
  }

  Future<DateTime?> _openDatePicker(DateTime initialDateTime) {
    return showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      locale: i18n.locale,
    );
  }

  void _onStartDateTap() async {
    DateTime? newStart = await _openDatePicker(_customCourse.dateStart);
    if (newStart == null) return;

    newStart = Date.setTimeFromOther(newStart, _customCourse.dateStart);
    if (newStart.isAfter(_customCourse.dateEnd)) {
      _customCourse.dateEnd = newStart;
    }

    _updateTimes(newStart, _customCourse.dateEnd);
  }

  void _onEndDateTap() async {
    DateTime? newEnd = await _openDatePicker(_customCourse.dateEnd);
    if (newEnd == null) return;

    newEnd = Date.setTimeFromOther(newEnd, _customCourse.dateEnd);
    if (newEnd.isBefore(_customCourse.dateStart)) {
      _customCourse.dateStart = newEnd;
    }

    _updateTimes(_customCourse.dateStart, newEnd);
  }

  void _onStartTimeTap() async {
    TimeOfDay? timeStart = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_customCourse.dateStart),
    );
    if (timeStart == null) return;

    final newStart = Date.changeTime(
      _customCourse.dateStart,
      hour: timeStart.hour,
      minute: timeStart.minute,
    );
    if (newStart.isSameOrAfter(_customCourse.dateEnd)) {
      final prevDuration = _customCourse.dateEnd.difference(
        _customCourse.dateStart,
      );
      _customCourse.dateEnd = newStart.add(prevDuration);
    }

    _updateTimes(newStart, _customCourse.dateEnd);
  }

  void _onEndTimeTap() async {
    TimeOfDay? timeEnd = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_customCourse.dateEnd),
    );
    if (timeEnd == null) return;

    final newEnd = Date.changeTime(
      _customCourse.dateEnd,
      hour: timeEnd.hour,
      minute: timeEnd.minute,
    );
    if (newEnd.isSameOrBefore(_customCourse.dateStart)) {
      final prevDuration = _customCourse.dateEnd.difference(
        _customCourse.dateStart,
      );
      _customCourse.dateStart = newEnd.subtract(prevDuration);
    }

    _updateTimes(_customCourse.dateStart, newEnd);
  }

  void _updateTimes(DateTime start, DateTime end) {
    setState(() {
      if (!_isAllDay) {
        _prevStartTime = TimeOfDay.fromDateTime(start);
        _prevEndTime = TimeOfDay.fromDateTime(end);
      }
      _customCourse.dateStart = start;
      _customCourse.dateEnd = end;
    });
  }

  Widget _buildDateTimeField(String title, String value) {
    return IgnorePointer(
      child: TextField(
        readOnly: true,
        autofocus: false,
        controller: TextEditingController(text: value),
        decoration: InputDecoration(labelText: title, border: InputBorder.none),
      ),
    );
  }

  void _onSubmit(BuildContext context) async {
    if (_customCourse.title.isEmpty) {
      _showError(i18n.text(StrKey.REQUIRE_FIELD));
      return;
    }
    if (_customCourse.dateEnd.isBefore(_customCourse.dateStart)) {
      DialogPredefined.showEndTimeError(context);
      return;
    }
    if (_isRecurrent && !_customCourse.isRecurrentEvent()) {
      _showError(i18n.text(StrKey.ERROR_EVENT_RECURRENT_ZERO));
      return;
    }
    if (_customCourse.uid.isEmpty) _customCourse.uid = const Uuid().v1();
    if (!_isRecurrent) _customCourse.weekdaysRepeat = [];
    if (!_isColor) _customCourse.color = null;

    Navigator.of(context).pop(_customCourse);
  }

  void _showError(String msg) {
    DialogPredefined.showSimpleMessage(
      context,
      i18n.text(StrKey.ERROR),
      msg,
    );
  }

  InputDecoration _buildInputDecoration(IconData icon, String hintText) {
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.only(right: 32.0, left: 16.0),
        child: Icon(icon),
      ),
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
      border: InputBorder.none,
    );
  }

  List<Widget> _buildWeekDaySelection() {
    List<String> weekDaysText = [
      i18n.text(StrKey.MONDAY).substring(0, 1),
      i18n.text(StrKey.TUESDAY).substring(0, 1),
      i18n.text(StrKey.WEDNESDAY).substring(0, 1),
      i18n.text(StrKey.THURSDAY).substring(0, 1),
      i18n.text(StrKey.FRIDAY).substring(0, 1),
      i18n.text(StrKey.SATURDAY).substring(0, 1),
      i18n.text(StrKey.SUNDAY).substring(0, 1),
    ];

    List<Widget> weekDayChips = WeekDay.values.map((weekday) {
      return CircleText(
        onChange: (newSelected) {
          setState(() {
            if (newSelected) {
              _customCourse.weekdaysRepeat.add(weekday);
            } else {
              _customCourse.weekdaysRepeat.remove(weekday);
            }
          });
        },
        text: weekDaysText[weekday.value - 1],
        isSelected: _customCourse.weekdaysRepeat.contains(weekday),
      );
    }).toList();

    return weekDayChips;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: AppbarPage(
        title: i18n.text(
          widget.course == null ? StrKey.ADD_EVENT : StrKey.EDIT_EVENT,
        ),
        fab: FloatingActionButton.extended(
          icon: const Icon(Icons.check),
          label: Text(i18n.text(StrKey.SAVE)),
          tooltip: i18n.text(StrKey.SAVE),
          heroTag: 'fabBtn',
          onPressed: () => _onSubmit(context),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: TextEditingController(text: _customCourse.title),
                onChanged: (title) {
                  _customCourse.title = title;
                },
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  Icons.title,
                  i18n.text(StrKey.TITLE_EVENT),
                ),
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_descNode),
              ),
              const Divider(height: 0.0),
              TextField(
                controller: TextEditingController(
                  text: _customCourse.description,
                ),
                focusNode: _descNode,
                textInputAction: TextInputAction.next,
                onChanged: (desc) {
                  _customCourse.description = desc;
                },
                decoration: _buildInputDecoration(
                  Icons.description,
                  i18n.text(StrKey.DESC_EVENT),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_locationNode),
              ),
              const Divider(height: 0.0),
              TextField(
                controller: TextEditingController(text: _customCourse.location),
                focusNode: _locationNode,
                textInputAction: TextInputAction.next,
                onChanged: (loc) {
                  _customCourse.location = loc;
                },
                decoration: _buildInputDecoration(
                  Icons.location_on_outlined,
                  i18n.text(StrKey.LOCATION_EVENT),
                ),
              ),
              const Divider(height: 0.0),
              ListTile(
                onTap: () => _onRecurrentDate(!_isRecurrent),
                leading: const Icon(Icons.repeat),
                title: Text(i18n.text(StrKey.EVENT_REPEAT)),
                trailing: Switch(
                  value: _isRecurrent,
                  activeColor: colorScheme.secondary,
                  onChanged: _onRecurrentDate,
                ),
              ),
              const Divider(height: 0.0),
              if (_isRecurrent)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 5.0,
                    children: _buildWeekDaySelection(),
                  ),
                ),
              if (!_isRecurrent)
                Column(
                  children: [
                    ListTile(
                      onTap: () => _onAllDay(!_isAllDay),
                      leading: const Icon(Icons.access_time),
                      // TODO: Add translation
                      title: const Text('Toute la journée'),
                      trailing: Switch(
                        value: _isAllDay,
                        activeColor: colorScheme.secondary,
                        onChanged: _onAllDay,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: ListTile(
                            onTap: _onStartDateTap,
                            leading: const Icon(null),
                            title: _buildDateTimeField(
                              // TODO: Refacto translation
                              '${i18n.text(StrKey.DATE_EVENT)} de début',
                              Date.extractDate(_customCourse.dateStart),
                            ),
                          ),
                        ),
                        if (!_isAllDay)
                          Expanded(
                            flex: 3,
                            child: ListTile(
                              onTap: _onStartTimeTap,
                              title: _buildDateTimeField(
                                i18n.text(StrKey.START_TIME_EVENT),
                                Date.extractTime(_customCourse.dateStart),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: ListTile(
                            onTap: _onEndDateTap,
                            leading: const Icon(null),
                            title: _buildDateTimeField(
                              // TODO: Refacto translation
                              '${i18n.text(StrKey.DATE_EVENT)} de fin',
                              Date.extractDate(_customCourse.dateEnd),
                            ),
                          ),
                        ),
                        if (!_isAllDay)
                          Expanded(
                            flex: 3,
                            child: ListTile(
                              onTap: _onEndTimeTap,
                              title: _buildDateTimeField(
                                i18n.text(StrKey.END_TIME_EVENT),
                                Date.extractTime(_customCourse.dateEnd),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              const Divider(height: 0.0),
              ListTile(
                onTap: () => _onColorCustom(!_isColor),
                leading: const Icon(Icons.color_lens_outlined),
                title: Text(i18n.text(StrKey.EVENT_COLOR)),
                trailing: Switch(
                  value: _isColor,
                  activeColor: colorScheme.secondary,
                  onChanged: _onColorCustom,
                ),
              ),
              if (_isColor)
                ListTileColor(
                  title: i18n.text(StrKey.EVENT_COLOR),
                  description: i18n.text(StrKey.EVENT_COLOR_DESC),
                  selectedColor: _customCourse.color,
                  onColorChange: (color) {
                    setState(() => _customCourse.color = color);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final originCourse = (widget.course ?? _baseCourse);

    if (originCourse != _customCourse ||
        _isColor != originCourse.hasColor() ||
        _isRecurrent != originCourse.isRecurrentEvent()) {
      bool confirmQuit = await DialogPredefined.showTextDialog(
        context,
        i18n.text(StrKey.CUSTOM_EVENT_EXIT_UNSAVED),
        i18n.text(StrKey.CUSTOM_EVENT_EXIT_UNSAVED_TEXT),
        i18n.text(StrKey.YES),
        i18n.text(StrKey.NO),
      );
      return confirmQuit;
    }
    return true;
  }
}
