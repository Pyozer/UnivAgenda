import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course/course_note.dart';

class DetailCourse extends StatefulWidget {
  final Course course;

  const DetailCourse({Key key, @required this.course})
      : assert(course != null),
        super(key: key);

  @override
  _DetailCourseState createState() => _DetailCourseState();
}

class _DetailCourseState extends State<DetailCourse> {
  List<Note> courseNotes = [];
  String noteToAdd;

  @override
  void initState() {
    super.initState();
    // TODO: TEMPORAIRE
    for (int i = 0; i < 5; i++) {
      widget.course.notes.add(
          Note(courseUid: widget.course.uid, text: "Une super note numéro $i"));
    }
    courseNotes = widget.course.notes;
  }

  List<Widget> _buildInfo(Translations translate, ThemeData theme) {
    final locale = translate.locale;

    final timeStart = Date.extractTime(widget.course.dateStart, locale);
    final timeEnd = Date.extractTime(widget.course.dateEnd, locale);
    final date = Date.dateFromNow(widget.course.dateStart, locale);

    List<Widget> listInfo = [
      ListTile(
          leading: Icon(Icons.access_time),
          title: Text(timeStart + "  –  " + timeEnd),
          subtitle: Text(date)),
      ListTile(
          leading: Icon(Icons.group),
          title: Text(widget.course.description,
              maxLines: 2, overflow: TextOverflow.ellipsis))
    ];

    if (widget.course.location != null && widget.course.location.isNotEmpty)
      listInfo.add(ListTile(
          leading: Icon(Icons.location_on),
          title: Text(widget.course.location)));

    if (widget.course.isExam())
      listInfo.add(ListTile(
          leading: Icon(Icons.description),
          title: Text(translate.get(StringKey.COURSE_TEST))));

    // TODO: Supprimer UID, temporaire
    listInfo.add(ListTile(
        leading: Icon(Icons.attach_file), title: Text(widget.course.uid)));

    // TODO: Ajout traduction
    listInfo.add(Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 16.0),
        child: Text("Notes",
            style:
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700))));

    // TODO: Ajouter traduction
    listInfo.add(Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(children: [
          Expanded(
              child: OutlineButton(
                  child: Text('ADD NOTE'), onPressed: _openAddNote))
        ])));

    listInfo.addAll(_buildListNotes());

    return listInfo;
  }

  List<Widget> _buildListNotes() {
    List<Widget> listNotes = [];
    courseNotes.forEach((note) {
      listNotes.add(CourseNote(note: note, onDelete: _onNoteDeleted));
    });

    return listNotes;
  }

  void _onNoteDeleted(Note noteToDelete) {
    setState(() {
      courseNotes.remove(noteToDelete);
    });
  }

  void _openAddNote() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // TODO: Ajouter traduction
        return AlertDialog(
          title: Text('Add a note'),
          content: TextField(
              maxLines: 3,
              decoration: InputDecoration(hintText: 'Enter the note'),
              onChanged: (value) {
                setState(() {
                  noteToAdd = value;
                });
              }),
          actions: [
            FlatButton(
              child: Text(Translations.of(context).get(StringKey.CANCEL).toUpperCase()),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FlatButton(
              child: Text("ADD NOTE"),
              onPressed: () {
                setState(() {
                  courseNotes
                      .add(Note(courseUid: widget.course.uid, text: noteToAdd));
                });
                Navigator.of(dialogContext).pop();
              },
            )
          ],
        );
      },
    );
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
          Expanded(child: ListView(children: _buildInfo(translate, theme)))
        ])));
  }
}
