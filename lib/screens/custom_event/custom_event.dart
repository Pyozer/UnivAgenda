import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/courses/custom_course.dart';
import 'package:myagenda/models/courses/weekday.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/widgets/settings/list_tile_color.dart';
import 'package:myagenda/widgets/ui/circle_text.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:uuid/uuid.dart';

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

  CustomCourse _baseCourse;

  @override
  void initState() {
    super.initState();
    final DateTime date = DateTime.now();
    _initFirstDate = Date.changeTime(date, 15, 0);
    _initEndDate = Date.changeTime(date, 16, 30);

    _baseCourse = CustomCourse(null, "", "", "", _initFirstDate, _initEndDate);

    // Init view
    if (widget.course != null) {
      _customCourse = CustomCourse.copy(widget.course);
      _isRecurrent = _customCourse.isRecurrentEvent();
      _isColor = _customCourse.hasColor();
    } else
      _customCourse =
          CustomCourse(null, "", "", "", _initFirstDate, _initEndDate);
  }

  @override
  void dispose() {
    _descNode.dispose();
    _locationNode.dispose();
    super.dispose();
  }

  void _onRecurrentDate(bool value) {
    setState(() {
      _isRecurrent = value;
    });
  }

  void _onColorCustom(bool value) {
    setState(() {
      _isColor = value;
    });
  }

  void _onDateTap() async {
    DateTime dateStart = await showDatePicker(
      context: context,
      initialDate: _customCourse.dateStart,
      firstDate: Date.dateFromDateTime(_initFirstDate),
      lastDate: DateTime(2030),
      locale: translations.locale,
    );

    if (dateStart != null) {
      final newStart = Date.changeTime(dateStart, _customCourse.dateStart.hour,
          _customCourse.dateStart.minute);

      _updateTimes(newStart, _customCourse.dateEnd);
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

  void _onSubmit(BuildContext context) {
    if (_customCourse.title.isEmpty ||
        _customCourse.description.isEmpty ||
        _customCourse.location.isEmpty) {
      _showError(translations.get(StringKey.REQUIRE_FIELD));
      return;
    }
    if (_customCourse.dateEnd.isBefore(_customCourse.dateStart)) {
      DialogPredefined.showEndTimeError(context);
      return;
    }
    if (_isRecurrent && _customCourse.weekdaysRepeat.length == 0) {
      _showError(translations.get(StringKey.ERROR_EVENT_RECURRENT_ZERO));
      return;
    }

    _customCourse.uid ??= Uuid().v1();
    if (!_isRecurrent) _customCourse.weekdaysRepeat = [];
    if (!_isColor) _customCourse.color = null;

    Navigator.of(context).pop(_customCourse);
  }

  void _showError(String msg) {
    DialogPredefined.showSimpleMessage(
      context,
      translations.get(StringKey.ERROR),
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
      translations.get(StringKey.MONDAY).substring(0, 1),
      translations.get(StringKey.TUESDAY).substring(0, 1),
      translations.get(StringKey.WEDNESDAY).substring(0, 1),
      translations.get(StringKey.THURSDAY).substring(0, 1),
      translations.get(StringKey.FRIDAY).substring(0, 1),
      translations.get(StringKey.SATURDAY).substring(0, 1),
      translations.get(StringKey.SUNDAY).substring(0, 1),
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
        title: translations.get(StringKey.ADD_EVENT),
        actions: [
          IconButton(
            icon: const Icon(OMIcons.check),
            tooltip: translations.get(StringKey.SAVE),
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
                  translations.get(StringKey.TITLE_EVENT),
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
                  translations.get(StringKey.DESC_EVENT),
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
                  translations.get(StringKey.LOCATION_EVENT),
                ),
                onEditingComplete: _onDateTap,
              ),
              const Divider(height: 0.0),
              ListTile(
                onTap: () => _onRecurrentDate(!_isRecurrent),
                leading: const Icon(OMIcons.repeat),
                title: Text(translations.get(StringKey.EVENT_REPEAT)),
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
                        translations.get(StringKey.DATE_EVENT),
                        Date.extractDate(
                            _customCourse.dateStart, translations.locale),
                      ),
                    ),
              const Divider(height: 0.0),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 11,
                    child: ListTile(
                      onTap: _onStartTimeTap,
                      leading: const Icon(OMIcons.timelapse),
                      title: _buildDateTimeField(
                        translations.get(StringKey.START_TIME_EVENT),
                        Date.extractTime(
                            _customCourse.dateStart, translations.locale),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: ListTile(
                      onTap: _onEndTimeTap,
                      title: _buildDateTimeField(
                        translations.get(StringKey.END_TIME_EVENT),
                        Date.extractTime(
                            _customCourse.dateEnd, translations.locale),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 0.0),
              ListTile(
                onTap: () => _onColorCustom(!_isColor),
                leading: const Icon(OMIcons.colorLens),
                title: Text(translations.get(StringKey.EVENT_COLOR)),
                trailing: Switch(
                  value: _isColor,
                  activeColor: theme.accentColor,
                  onChanged: _onColorCustom,
                ),
              ),
              _isColor
                  ? ListTileColor(
                      title: translations.get(StringKey.EVENT_COLOR),
                      description: translations.get(StringKey.EVENT_COLOR_DESC),
                      selectedColor: _customCourse.color,
                      onColorChange: (color) {
                        setState(() {
                          _customCourse.color = color;
                        });
                      },
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
        translations.get(StringKey.CUSTOM_EVENT_EXIT_UNSAVED),
        translations.get(StringKey.CUSTOM_EVENT_EXIT_UNSAVED_TEXT),
        translations.get(StringKey.YES),
        translations.get(StringKey.NO),
      );
      return confirmQuit;
    }
    return true;
  }
}
