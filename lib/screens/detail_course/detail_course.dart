import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course/course_note.dart';
import 'package:myagenda/widgets/ui/about_card.dart';

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

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      final noteTEST = Note(courseUid: "lol", text: "Une super note numéro $i");
      widget.course.notes.add(noteTEST);
    }
    courseNotes = widget.course.notes;
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(children: [
      Expanded(
          child: Material(
              color: theme.primaryColor,
              elevation: 4.0,
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  child: Text(widget.course.title,
                      style: const TextStyle(fontSize: 17.0)))))
    ]);
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

    listInfo.add(Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Text("Notes",
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
    ));
    listInfo.addAll(_buildListNotes());

    return listInfo;
  }

  List<Widget> _buildListNotes() {
    List<Widget> listNotes = [];
    if (courseNotes.length > 0)
      courseNotes.forEach((note) {
        listNotes.add(CourseNote(
            note: note,
            onDelete: (noteToRemove) {
              setState(() {
                courseNotes.remove(note);
              });
            }));
      });
    else
      listNotes.add(AboutCard(title: "Aucune note :/"));
    return listNotes;
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
          _buildHeader(theme),
          Expanded(child: ListView(children: _buildInfo(translate, theme)))
        ])));
  }
}
