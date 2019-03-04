import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/courses/custom_course.dart';
import 'package:myagenda/models/courses/weekday.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/settings/list_tile_choices.dart';
import 'package:myagenda/widgets/settings/list_tile_color.dart';
import 'package:myagenda/widgets/ui/circle_text.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:device_calendar/device_calendar.dart' as Calendar;

class CustomEventScreen extends StatefulWidget {
  final CustomCourse course;

  const CustomEventScreen({Key key, this.course}) : super(key: key);

  @override
  _CustomEventScreenState createState() => _CustomEventScreenState();
}

class _CustomEventScreenState extends BaseState<CustomEventScreen> {
  final _descNode = FocusNode();
  final _locationNode = FocusNode();

  DateTime _initFirstDate;
  DateTime _initEndDate;

  bool _isRecurrent = false;
  bool _isColor = false;
  CustomCourse _customCourse;

  List<Calendar.Calendar> _deviceCalendars = [];

  CustomCourse _baseCourse;

  @override
  void initState() {
    super.initState();
    _initFirstDate = DateTime.now().add(Duration(minutes: 30));
    _initEndDate = _initFirstDate.add(Duration(hours: 1));

    _baseCourse = CustomCourse(null, "", "", "", _initFirstDate, _initEndDate);

    // Init view
    if (widget.course != null) {
      _customCourse = CustomCourse.copy(widget.course);
      _isRecurrent = _customCourse.isRecurrentEvent();
      _isColor = _customCourse.hasColor();
      if (_customCourse.syncCalendar != null) _getCalendars();
    } else
      _customCourse =
          CustomCourse(null, "", "", "", _initFirstDate, _initEndDate);
  }

  void _getCalendars() async {
    final calendarPlugin = Calendar.DeviceCalendarPlugin();
    try {
      var permissionsGranted = await calendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await calendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(translations.text(StrKey.GET_CALENDARS_FAILED)),
          ));
          return;
        }
      }

      final calendarsResult = await calendarPlugin.retrieveCalendars();
      setState(() {
        _deviceCalendars = calendarsResult.data ?? [];
        if (_customCourse.syncCalendar == null)
          _customCourse.syncCalendar = _deviceCalendars.first ?? null;
      });
    } catch (e) {
      print(e.toString());
    }
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

  void _onColorCustom(bool value) {
    setState(() => _isColor = value);
  }

  void _onSyncCalendar(bool value) {
    if (value)
      _getCalendars();
    else
      setState(() => _customCourse.syncCalendar = null);
  }

  void _onDateTap() async {
    DateTime dateStart = await showDatePicker(
      context: context,
      initialDate: _customCourse.dateStart,
      firstDate: Date.dateFromDateTime(_initFirstDate),
      lastDate: DateTime.now().add(Duration(days: 365 * 30)),
      locale: translations.locale,
    );

    if (dateStart != null) {
      final newStart = Date.changeTime(dateStart, _customCourse.dateStart.hour,
          _customCourse.dateStart.minute);

      final newEnd = Date.changeTime(
          dateStart, _customCourse.dateEnd.hour, _customCourse.dateEnd.minute);

      _updateTimes(newStart, newEnd);
    }
  }

  void _onStartTimeTap() async {
    TimeOfDay timeStart = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_customCourse.dateStart),
    );

    if (timeStart != null) {
      final newStart = Date.changeTime(
          _customCourse.dateStart, timeStart.hour, timeStart.minute);

      _updateTimes(newStart, _customCourse.dateEnd);
    }
  }

  void _onEndTimeTap() async {
    TimeOfDay timeEnd = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_customCourse.dateEnd),
    );

    if (timeEnd != null) {
      final newEnd = Date.changeTime(
          _customCourse.dateStart, timeEnd.hour, timeEnd.minute);

      _updateTimes(_customCourse.dateStart, newEnd);
    }
  }

  void _updateTimes(DateTime start, DateTime end) {
    setState(() {
      _customCourse.dateStart = start;
      _customCourse.dateEnd = end;
    });
  }

  Widget _buildDateTimeField(String title, String value) {
    return TextField(
      enabled: false,
      autofocus: false,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(labelText: title, border: InputBorder.none),
    );
  }

  void _onSubmit(BuildContext context) async {
    if (_customCourse.title.isEmpty ||
        _customCourse.description.isEmpty ||
        _customCourse.location.isEmpty) {
      _showError(translations.text(StrKey.REQUIRE_FIELD));
      return;
    }
    if (_customCourse.dateEnd.isBefore(_customCourse.dateStart)) {
      DialogPredefined.showEndTimeError(context);
      return;
    }
    if (_customCourse.dateEnd.isBefore(DateTime.now())) {
      DialogPredefined.showEndTimeError(context);
      return;
    }
    if (_isRecurrent && _customCourse.weekdaysRepeat.length == 0) {
      _showError(translations.text(StrKey.ERROR_EVENT_RECURRENT_ZERO));
      return;
    }
    _customCourse.uid ??= Uuid().v1();
    if (!_isRecurrent) _customCourse.weekdaysRepeat = [];
    if (!_isColor) _customCourse.color = null;

    if (_customCourse.syncCalendar != null) {
      final eventToCreate = Calendar.Event(
        _customCourse.syncCalendar.id,
        eventId: _customCourse.uid,
        title: _customCourse.title,
        description: _customCourse.description,
        start: _customCourse.dateStart,
        end: _customCourse.dateEnd,
      );

      final createEventResult = await Calendar.DeviceCalendarPlugin()
          .createOrUpdateEvent(eventToCreate);
      if (!createEventResult.isSuccess) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(translations.text(StrKey.ADD_TO_CALENDAR_FAILED)),
        ));
      }
    }

    Navigator.of(context).pop(_customCourse);
  }

  void _showError(String msg) {
    DialogPredefined.showSimpleMessage(
      context,
      translations.text(StrKey.ERROR),
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
      translations.text(StrKey.MONDAY).substring(0, 1),
      translations.text(StrKey.TUESDAY).substring(0, 1),
      translations.text(StrKey.WEDNESDAY).substring(0, 1),
      translations.text(StrKey.THURSDAY).substring(0, 1),
      translations.text(StrKey.FRIDAY).substring(0, 1),
      translations.text(StrKey.SATURDAY).substring(0, 1),
      translations.text(StrKey.SUNDAY).substring(0, 1),
    ];

    List<Widget> weekDayChips = [];

    WeekDay.values.forEach((weekday) {
      weekDayChips.add(
        CircleText(
          onChange: (newSelected) {
            setState(() {
              if (newSelected)
                _customCourse.weekdaysRepeat.add(weekday);
              else
                _customCourse.weekdaysRepeat.remove(weekday);
            });
          },
          text: weekDaysText[weekday.value - 1],
          isSelected: _customCourse.weekdaysRepeat.contains(weekday),
        ),
      );
    });

    return weekDayChips;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AppbarPage(
        title: translations.text(
          widget.course == null ? StrKey.ADD_EVENT : StrKey.EDIT_EVENT,
        ),
        actions: [
          IconButton(
            icon: const Icon(OMIcons.check),
            tooltip: translations.text(StrKey.SAVE),
            onPressed: () => _onSubmit(context),
          )
        ],
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
                  OMIcons.title,
                  translations.text(StrKey.TITLE_EVENT),
                ),
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_descNode),
              ),
              const Divider(height: 0.0),
              TextField(
                controller:
                    TextEditingController(text: _customCourse.description),
                focusNode: _descNode,
                textInputAction: TextInputAction.next,
                onChanged: (desc) {
                  _customCourse.description = desc;
                },
                decoration: _buildInputDecoration(
                  OMIcons.description,
                  translations.text(StrKey.DESC_EVENT),
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
                  OMIcons.locationOn,
                  translations.text(StrKey.LOCATION_EVENT),
                ),
                onEditingComplete: _onDateTap,
              ),
              const Divider(height: 0.0),
              ListTile(
                onTap: () => _onRecurrentDate(!_isRecurrent),
                leading: const Icon(OMIcons.repeat),
                title: Text(translations.text(StrKey.EVENT_REPEAT)),
                trailing: Switch(
                  value: _isRecurrent,
                  activeColor: theme.accentColor,
                  onChanged: _onRecurrentDate,
                ),
              ),
              const Divider(height: 0.0),
              _isRecurrent
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 5.0,
                        children: _buildWeekDaySelection(),
                      ),
                    )
                  : ListTile(
                      onTap: _onDateTap,
                      leading: const Icon(OMIcons.dateRange),
                      title: _buildDateTimeField(
                        translations.text(StrKey.DATE_EVENT),
                        Date.extractDate(_customCourse.dateStart),
                      ),
                    ),
              const Divider(height: 0.0),
              Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: ListTile(
                      onTap: _onStartTimeTap,
                      leading: const Icon(OMIcons.timelapse),
                      title: _buildDateTimeField(
                        translations.text(StrKey.START_TIME_EVENT),
                        Date.extractTime(_customCourse.dateStart),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: ListTile(
                      onTap: _onEndTimeTap,
                      title: _buildDateTimeField(
                        translations.text(StrKey.END_TIME_EVENT),
                        Date.extractTime(_customCourse.dateEnd),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 0.0),
              ListTile(
                onTap: () => _onColorCustom(!_isColor),
                leading: const Icon(OMIcons.colorLens),
                title: Text(translations.text(StrKey.EVENT_COLOR)),
                trailing: Switch(
                  value: _isColor,
                  activeColor: theme.accentColor,
                  onChanged: _onColorCustom,
                ),
              ),
              _isColor
                  ? ListTileColor(
                      title: translations.text(StrKey.EVENT_COLOR),
                      description: translations.text(StrKey.EVENT_COLOR_DESC),
                      selectedColor: _customCourse.color,
                      onColorChange: (color) {
                        setState(() => _customCourse.color = color);
                      },
                    )
                  : const SizedBox.shrink(),
              const Divider(height: 0.0),
              ListTile(
                onTap: () =>
                    _onSyncCalendar(!(_customCourse.syncCalendar != null)),
                leading: const Icon(OMIcons.calendarToday),
                title: Text(translations.text(StrKey.SYNC_CALENDAR)),
                trailing: Switch(
                  value: _customCourse.syncCalendar != null,
                  activeColor: theme.accentColor,
                  onChanged: _onSyncCalendar,
                ),
              ),
              _customCourse.syncCalendar != null
                  ? ListTileChoices(
                      title: translations.text(StrKey.CHOOSE_CALENDAR),
                      values: _deviceCalendars.map((c) => c.name).toList(),
                      onChange: (calendar) {
                        setState(() {
                          _customCourse.syncCalendar =
                              _deviceCalendars.firstWhere(
                            (c) => c.name == calendar,
                            orElse: () => null,
                          );
                        });
                      },
                      selectedValue: _customCourse.syncCalendar?.name,
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final _originCourse = (widget.course ?? _baseCourse);
    bool isEquals = (_originCourse == _customCourse &&
        _isColor == _originCourse.hasColor() &&
        _isRecurrent == _originCourse.isRecurrentEvent());

    if (!isEquals) {
      bool confirmQuit = await DialogPredefined.showTextDialog(
        context,
        translations.text(StrKey.CUSTOM_EVENT_EXIT_UNSAVED),
        translations.text(StrKey.CUSTOM_EVENT_EXIT_UNSAVED_TEXT),
        translations.text(StrKey.YES),
        translations.text(StrKey.NO),
      );
      return confirmQuit;
    }
    return true;
  }
}
