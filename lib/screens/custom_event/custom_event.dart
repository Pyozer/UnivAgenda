import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
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
  final DateTime _firstDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final _descNode = FocusNode();
  final TextEditingController _locationController = TextEditingController();
  final _locationNode = FocusNode();

  bool _isCustomColor = false;
  bool _isEventRecurrent = false;
  List<WeekDay> _selectedWeekdays = [];

  DateTime _eventDateStart;
  DateTime _eventDateEnd;
  Color _eventColor;

  @override
  void initState() {
    super.initState();
    // Init view
    if (widget.course != null) {
      _eventDateStart = widget.course.dateStart;
      _eventDateEnd = widget.course.dateEnd;

      _titleController.text = widget.course.title;
      _descController.text = widget.course.description;
      _locationController.text = widget.course.location;

      _isEventRecurrent = widget.course.isRecurrentEvent();
      _selectedWeekdays = widget.course.weekdaysRepeat;

      _isCustomColor = widget.course.color != null;
      _eventColor = widget.course.color ?? materialColors[0];
    } else {
      _eventDateStart = DateTime.now();
      _eventDateEnd = DateTime.now();
      _eventColor = materialColors[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _descNode.dispose();
    _locationNode.dispose();
    super.dispose();
  }

  void _onRecurrentDate(bool value) {
    setState(() {
      _isEventRecurrent = value;
    });
  }

  void _onColorCustom(bool value) {
    setState(() {
      _isCustomColor = value;
    });
  }

  void _onDateTap() async {
    DateTime dateStart = await showDatePicker(
      context: context,
      initialDate: _eventDateStart,
      firstDate: _firstDate,
      lastDate: DateTime(2030),
      locale: translations.locale,
    );

    if (dateStart != null) {
      final newStart = DateTime(dateStart.year, dateStart.month, dateStart.day,
          _eventDateStart.hour, _eventDateStart.minute);

      _updateTimes(newStart, _eventDateEnd);
    }
  }

  void _onStartTimeTap() async {
    TimeOfDay timeStart = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDateStart),
    );

    if (timeStart != null) {
      final newStart = DateTime(_eventDateStart.year, _eventDateStart.month,
          _eventDateStart.day, timeStart.hour, timeStart.minute);

      _updateTimes(newStart, _eventDateEnd);
    }
  }

  void _onEndTimeTap() async {
    TimeOfDay timeEnd = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDateEnd),
    );

    if (timeEnd != null) {
      final newEnd = DateTime(_eventDateStart.year, _eventDateStart.month,
          _eventDateStart.day, timeEnd.hour, timeEnd.minute);

      _updateTimes(_eventDateStart, newEnd);
    }
  }

  void _updateTimes(DateTime start, DateTime end) {
    setState(() {
      _eventDateStart = start;
      _eventDateEnd = end;
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
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _locationController.text.isEmpty) {
      _showError(translations.get(StringKey.REQUIRE_FIELD));
      return;
    }
    if (_eventDateEnd.isBefore(_eventDateStart)) {
      DialogPredefined.showEndTimeError(context);
      return;
    }
    if (_isEventRecurrent && _selectedWeekdays.length == 0) {
      _showError(translations.get(StringKey.ERROR_EVENT_RECURRENT_ZERO));
      return;
    }

    final course = CustomCourse(
      widget.course?.uid ?? Uuid().v1(),
      _titleController.text,
      _descController.text,
      _locationController.text,
      _eventDateStart,
      _eventDateEnd,
      notes: widget.course?.notes ?? [],
      color: (_isCustomColor && _eventColor != null) ? _eventColor : null,
      weekdaysRepeat: _isEventRecurrent ? _selectedWeekdays : [],
    );

    Navigator.of(context).pop(course);
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
                _selectedWeekdays.add(weekday);
              else
                _selectedWeekdays.remove(weekday);
            });
          },
          text: weekDaysText[weekday.value - 1],
          isSelected: _selectedWeekdays.contains(weekday),
        ),
      );
    });

    return weekDayChips;
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
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
            TextFormField(
              textInputAction: TextInputAction.next,
              controller: _titleController,
              decoration: _buildInputDecoration(
                OMIcons.title,
                translations.get(StringKey.TITLE_EVENT),
              ),
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_descNode),
            ),
            const Divider(height: 0.0),
            TextFormField(
              focusNode: _descNode,
              textInputAction: TextInputAction.next,
              controller: _descController,
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
            TextFormField(
              focusNode: _locationNode,
              textInputAction: TextInputAction.next,
              controller: _locationController,
              decoration: _buildInputDecoration(
                OMIcons.locationOn,
                translations.get(StringKey.LOCATION_EVENT),
              ),
              onEditingComplete: _onDateTap,
            ),
            const Divider(height: 0.0),
            ListTile(
              onTap: () => _onRecurrentDate(!_isEventRecurrent),
              leading: const Icon(OMIcons.repeat),
              title: Text(translations.get(StringKey.EVENT_REPEAT)),
              trailing: Switch(
                value: _isEventRecurrent,
                activeColor: theme.accentColor,
                onChanged: _onRecurrentDate,
              ),
            ),
            const Divider(height: 0.0),
            _isEventRecurrent
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
                      Date.extractDate(_eventDateStart, translations.locale),
                    ),
                  ),
            const Divider(height: 0.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    onTap: _onStartTimeTap,
                    leading: const Icon(OMIcons.accessTime),
                    title: _buildDateTimeField(
                      translations.get(StringKey.START_TIME_EVENT),
                      Date.extractTime(_eventDateStart, translations.locale),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    onTap: _onEndTimeTap,
                    leading: const Icon(OMIcons.accessTime),
                    title: _buildDateTimeField(
                      translations.get(StringKey.END_TIME_EVENT),
                      Date.extractTime(_eventDateEnd, translations.locale),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 0.0),
            ListTile(
              onTap: () => _onColorCustom(!_isCustomColor),
              leading: const Icon(OMIcons.colorLens),
              title: Text(translations.get(StringKey.EVENT_COLOR)),
              trailing: Switch(
                value: _isCustomColor,
                activeColor: theme.accentColor,
                onChanged: _onColorCustom,
              ),
            ),
            _isCustomColor
                ? ListTileColor(
                    title: translations.get(StringKey.EVENT_COLOR),
                    description: translations.get(StringKey.EVENT_COLOR_DESC),
                    selectedColor: _eventColor,
                    onColorChange: (color) {
                      setState(() {
                        _eventColor = color;
                      });
                    },
                  )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
