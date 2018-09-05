import 'package:color_picker/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/settings/list_tile_color.dart';
import 'package:myagenda/widgets/ui/end_time_error.dart';
import 'package:uuid/uuid.dart';

class CustomEventScreen extends StatefulWidget {
  final CustomCourse course;

  const CustomEventScreen({Key key, this.course}) : super(key: key);

  @override
  _CustomEventScreenState createState() => _CustomEventScreenState();
}

class _CustomEventScreenState extends State<CustomEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final DateTime _firstDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Locale _locale;
  bool _isCustomColor = false;

  DateTime _eventDateStart;
  DateTime _eventDateEnd;
  Color _eventColor;

  @override
  void initState() {
    super.initState();

    if (widget.course != null) {
      _eventDateStart = widget.course.dateStart;
      _eventDateEnd = widget.course.dateEnd;
      _eventColor = widget.course.color;
      _titleController.text = widget.course.title;
      _descController.text = widget.course.description;
      _locationController.text = widget.course.location;
      if (widget.course.color != null) {
        _isCustomColor = true;
      }
      _eventColor = widget.course.color ?? materialColors[0];
    } else {
      _eventDateStart = DateTime.now();
      _eventDateEnd = DateTime.now().add(Duration(hours: 1));
      _eventColor = materialColors[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onDateTap() async {
    DateTime dateStart = await showDatePicker(
      context: context,
      initialDate: _eventDateStart,
      firstDate: _firstDate,
      lastDate: DateTime(2030),
      locale: _locale,
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

  Widget _buildDateTimeField(
      String title, String value, GestureTapCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: TextField(
        enabled: false,
        autofocus: false,
        controller: TextEditingController(text: value),
        decoration: InputDecoration(labelText: title, border: InputBorder.none),
      ),
    );
  }

  String _validateTextField(String value) {
    if (value.isEmpty) {
      return Translations.of(context).get(StringKey.REQUIRE_FIELD);
    }
    return null;
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState.validate()) {

      // Check data
      if (_eventDateEnd.isBefore(_eventDateStart)) {
        DialogPredefined.showEndTimeError(context);
        return;
      }

      final course = CustomCourse(
        widget.course?.uid ?? Uuid().v1(),
        _titleController.text,
        _descController.text,
        _locationController.text,
        _eventDateStart,
        _eventDateEnd,
        widget.course?.notes ?? [],
        (_isCustomColor && _eventColor != null) ? _eventColor : null,
      );

      Navigator.of(context).pop(course);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    _locale = translations.locale;

    return AppbarPage(
      title: translations.get(StringKey.ADD_EVENT),
      actions: [
        IconButton(
            icon: const Icon(Icons.check), onPressed: () => _onSubmit(context))
      ],
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.title),
                title: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration.collapsed(hintText: translations.get(StringKey.TITLE_EVENT)),
                  validator: _validateTextField,
                ),
              ),
              Divider(height: 4.0),
              ListTile(
                leading: const Icon(Icons.description),
                title: TextFormField(
                  controller: _descController,
                  decoration:
                      InputDecoration.collapsed(hintText: translations.get(StringKey.DESC_EVENT)),
                  validator: _validateTextField,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              Divider(height: 4.0),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration.collapsed(hintText: translations.get(StringKey.LOCATION_EVENT)),
                  validator: _validateTextField,
                ),
              ),
              Divider(height: 4.0),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: _buildDateTimeField(
                  translations.get(StringKey.DATE_EVENT),
                  Date.extractDate(_eventDateStart, _locale),
                  _onDateTap,
                ),
              ),
              Divider(height: 4.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: _buildDateTimeField(
                        translations.get(StringKey.START_TIME_EVENT),
                        Date.extractTime(_eventDateStart, _locale),
                        _onStartTimeTap,
                      ),
                    ),
                  ),
                  Container(width: 16.0),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: _buildDateTimeField(
                        translations.get(StringKey.END_TIME_EVENT),
                        Date.extractTime(_eventDateEnd, _locale),
                        _onEndTimeTap,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 4.0),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: Text(translations.get(StringKey.EVENT_COLOR)),
                trailing: Switch(
                    value: _isCustomColor,
                    activeColor: Theme.of(context).accentColor,
                    onChanged: (value) {
                      setState(() {
                        _isCustomColor = value;
                      });
                    }),
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
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
