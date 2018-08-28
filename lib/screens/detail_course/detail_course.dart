import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course_note/add_note_button.dart';
import 'package:myagenda/widgets/course_note/course_note.dart';

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

  List<Widget> _buildInfo(Translations translate, ThemeData theme) {
    final locale = translate.locale;

    final timeStart = Date.extractTime(widget.course.dateStart, locale);
    final timeEnd = Date.extractTime(widget.course.dateEnd, locale);
    final date = Date.dateFromNow(widget.course.dateStart, locale);

    List<Widget> listInfo = [
      ListTile(
          leading: const Icon(Icons.access_time),
          title: Text('$timeStart  –  $timeEnd'),
          subtitle: Text(date)),
      ListTile(
          leading: const Icon(Icons.group),
          title: Text(widget.course.description,
              maxLines: 2, overflow: TextOverflow.ellipsis))
    ];

    if (widget.course.location != null && widget.course.location.isNotEmpty)
      listInfo.add(ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(widget.course.location)));

    if (widget.course.isExam())
      listInfo.add(ListTile(
          leading: const Icon(Icons.description),
          title: Text(translate.get(StringKey.COURSE_TEST))));

    listInfo.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 8.0),
            child: Text(translate.get(StringKey.NOTES),
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.w700))),
        AddNoteButton(onPressed: _openAddNote)
      ],
    ));

    listInfo.addAll(_buildListNotes());

    return listInfo;
  }

  List<Widget> _buildListNotes() {
    List<Widget> listNotes = [];

    for (final note in widget.course.notes)
      listNotes.add(CourseNote(note: note, onDelete: _onNoteDeleted));

    return listNotes;
  }

  void _onNoteDeleted(Note note) {
    setState(() {
      widget.course.notes.remove(note);
    });
    Preferences.removeNote(note);
  }

  void _openAddNote() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final translate = Translations.of(context);

        return AlertDialog(
          title: Text(translate.get(StringKey.ADD_NOTE)),
          content: Form(
            key: _formKey,
            child: TextFormField(
              maxLines: 3,
              decoration: InputDecoration(
                  hintText: translate.get(StringKey.ADD_NOTE_PLACEHOLDER)),
              validator: (val) => val.trim().isEmpty
                  ? translate.get(StringKey.ADD_NOTE_EMPTY)
                  : null,
              onSaved: (val) => _noteToAdd = val.trim(),
            ),
          ),
          actions: [
            FlatButton(
              child: Text(translate.get(StringKey.CANCEL).toUpperCase()),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FlatButton(
              child:
                  Text(translate.get(StringKey.ADD_NOTE_SUBMIT).toUpperCase()),
              onPressed: () => _submitAddNote(dialogContext),
            )
          ],
        );
      },
    );
  }

  void _submitAddNote(BuildContext context) {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();

      final note = Note(courseUid: widget.course.uid, text: _noteToAdd, dateExpiration: widget.course.dateEnd);
      _noteToAdd = "";

      setState(() {
        widget.course.notes.insert(0, note);
      });
      Preferences.addNote(note);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translations.of(context);

    final deleteBtn = (widget.course is CustomCourse) ? [
      IconButton(icon: const Icon(Icons.delete), onPressed: () {
        Preferences.removeEvent(widget.course);
        Navigator.of(context).pop();
      })
    ] : null;

    return AppbarPage(
        title: translate.get(StringKey.COURSE_DETAILS),
        elevation: 0.0,
        actions: deleteBtn,
        body: Container(
            child: Column(children: [
          AppbarSubTitle(subtitle: widget.course.title),
          Expanded(
              child: ListView(
                  shrinkWrap: true, children: _buildInfo(translate, theme)))
        ])));
  }
}
