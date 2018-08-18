import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/date.dart';
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
  List<Note> _courseNotes = [];

  final _formKey = GlobalKey<FormState>();
  String _noteToAdd;

  @override
  void initState() {
    super.initState();
    _courseNotes = widget.course.notes;
  }

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

    // TODO: Ajout traduction
    listInfo.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 8.0),
              child: Text("Notes",
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w700))),
          AddNoteButton(onPressed: _openAddNote)
        ],
      )
    );

    listInfo.addAll(_buildListNotes());

    return listInfo;
  }

  List<Widget> _buildListNotes() {
    List<Widget> listNotes = [];

    for (int i = 0; i < _courseNotes.length; i++) {
      final note = _courseNotes[i];
      listNotes.add(Dismissible(
          key: Key('$i'),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) => _onNoteDeleted(i),
          child: CourseNote(note: note)));
    }

    return listNotes;
  }

  void _onNoteDeleted(int index) {
    setState(() {
      _courseNotes.removeAt(index);
    });
  }

  void _openAddNote() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // TODO: Ajouter traductions
        return AlertDialog(
          title: Text('Add a note'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              maxLines: 3,
              decoration: InputDecoration(hintText: 'Enter the note'),
              validator: (val) =>
                  val.trim().isEmpty ? 'Note can\'t be empty.' : null,
              onSaved: (val) => _noteToAdd = val.trim(),
            ),
          ),
          actions: [
            FlatButton(
              child: Text(
                  Translations.of(context).get(StringKey.CANCEL).toUpperCase()),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FlatButton(
              child: Text("ADD NOTE"),
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

      setState(() {
        _courseNotes.add(Note(courseUid: widget.course.uid, text: _noteToAdd));
      });
      _noteToAdd = "";
      Navigator.of(context).pop();

      // TODO: Save note to shared_preferences

    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translations.of(context);

    return AppbarPage(
        title: translate.get(StringKey.COURSE_DETAILS),
        elevation: 0.0,
        body: Container(
            child: Column(children: [
          AppbarSubTitle(subtitle: widget.course.title),
          Expanded(child: ListView(shrinkWrap: true, children: _buildInfo(translate, theme)))
        ])));
  }
}
