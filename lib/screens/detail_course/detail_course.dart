import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/courses/custom_course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/custom_event/custom_event.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course_note/add_note_button.dart';
import 'package:myagenda/widgets/course_note/course_note.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class DetailCourse extends StatefulWidget {
  final Course course;

  const DetailCourse({Key key, @required this.course})
      : assert(course != null),
        super(key: key);

  @override
  _DetailCourseState createState() => _DetailCourseState();
}

class _DetailCourseState extends State<DetailCourse> {
  final _formKey = GlobalKey<FormState>();
  String _noteToAdd;
  Course _course;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
  }

  List<Widget> _buildInfo(Translations translate, ThemeData theme) {
    final locale = translate.locale;

    final timeStart = Date.extractTime(_course.dateStart, locale);
    final timeEnd = Date.extractTime(_course.dateEnd, locale);
    final date = Date.dateFromNow(_course.dateStart, locale);

    List<Widget> listInfo = [
      ListTile(
        leading: const Icon(OMIcons.accessTime),
        title: Text('$timeStart  –  $timeEnd'),
        subtitle: Text(date),
      ),
      ListTile(
        leading: const Icon(OMIcons.group),
        title: Text(
          _course.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      )
    ];

    if (_course.location != null && _course.location.isNotEmpty)
      listInfo.add(ListTile(
          leading: const Icon(OMIcons.locationOn),
          title: Text(_course.location)));

    if (_course.isExam())
      listInfo.add(ListTile(
          leading: const Icon(OMIcons.description),
          title: Text(translate.get(StringKey.COURSE_TEST))));

    if (_course.color != null)
      listInfo.add(
        ListTile(
          leading: const Icon(OMIcons.colorLens),
          title: Text(translate.get(StringKey.EVENT_COLOR)),
          trailing: CircleColor(color: _course.color, circleSize: 28.0),
        ),
      );

    listInfo.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 8.0),
          child: Text(
            translate.get(StringKey.NOTES),
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
          ),
        ),
        AddNoteButton(onPressed: _openAddNote)
      ],
    ));

    listInfo.addAll(_buildListNotes());

    return listInfo;
  }

  List<Widget> _buildListNotes() {
    List<Widget> listNotes = [];

    for (final note in _course.notes)
      listNotes.add(CourseNote(note: note, onDelete: _onNoteDeleted));

    return listNotes;
  }

  void _onNoteDeleted(Note note) {
    setState(() {
      _course.notes.remove(note);
    });
    PreferencesProvider.of(context).removeNote(note);
  }

  void _openAddNote() async {
    final translate = Translations.of(context);

    var formContent = Form(
      key: _formKey,
      child: TextFormField(
        maxLength: 350,
        maxLines: 6,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: translate.get(StringKey.ADD_NOTE_PLACEHOLDER),
        ),
        validator: (val) => (val.trim().isEmpty)
            ? translate.get(StringKey.ADD_NOTE_EMPTY)
            : null,
        onSaved: (val) => _noteToAdd = val.trim(),
      ),
    );

    bool isDialogPositive = await DialogPredefined.showContentDialog(
      context,
      translate.get(StringKey.ADD_NOTE),
      formContent,
      translate.get(StringKey.ADD_NOTE_SUBMIT),
      translate.get(StringKey.CANCEL),
    );

    if (isDialogPositive) _submitAddNote();
  }

  void _submitAddNote() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();

      DateTime dateEndNote = _course.dateEnd;
      if (_course is CustomCourse && (_course as CustomCourse).isRecurrentEvent()) {
        dateEndNote = null;
      }
      final note = Note(courseUid: _course.uid, text: _noteToAdd, dateEnd: dateEndNote);

      _noteToAdd = "";
      setState(() {
        _course.notes.insert(0, note);
      });

      PreferencesProvider.of(context).addNote(note, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translations.of(context);

    final actionsAppbar = (_course is CustomCourse)
        ? [
            IconButton(
              icon: const Icon(OMIcons.delete),
              onPressed: () async {
                bool isConfirm =
                    await DialogPredefined.showDeleteEventConfirm(context);
                if (isConfirm) {
                  PreferencesProvider.of(context).removeCustomEvent(_course, true);
                  Navigator.of(context).pop();
                }
              },
            ),
            IconButton(
              icon: const Icon(OMIcons.edit),
              onPressed: () async {
                CustomCourse editedCourse = await Navigator.of(context).push(
                  CustomRoute<CustomCourse>(
                      builder: (context) => CustomEventScreen(course: _course),
                      fullscreenDialog: true,
                      routeName: RouteKey.EDIT_EVENT),
                );

                if (editedCourse != null) {
                  PreferencesProvider.of(context).editCustomEvent(editedCourse, true);
                  setState(() {
                    _course = editedCourse;
                  });
                }
              },
            )
          ]
        : null;

    return AppbarPage(
      title: translate.get(StringKey.COURSE_DETAILS),
      elevation: 0.0,
      actions: actionsAppbar,
      body: Container(
        child: Column(
          children: [
            AppbarSubTitle(subtitle: _course.title),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: _buildInfo(translate, theme),
              ),
            )
          ],
        ),
      ),
    );
  }
}
