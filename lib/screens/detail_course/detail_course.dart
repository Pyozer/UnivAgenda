import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/courses/custom_course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/screens/custom_event/custom_event.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/date.dart';
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

class _DetailCourseState extends BaseState<DetailCourse> {
  final _formKey = GlobalKey<FormState>();
  String _noteToAdd;
  Course _course;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
  }

  List<Widget> _buildInfo() {
    final locale = Locale(Localizations.localeOf(context).languageCode ?? 'en');

    final timeStart = Date.extractTime(_course.dateStart, locale);
    final timeEnd = Date.extractTime(_course.dateEnd, locale);
    final date = Date.dateFromNow(_course.dateStart, locale);

    var duration = Date.calculateDuration(_course.dateStart, _course.dateEnd);
    String durationStr = "";
    if (duration.hour > 0) durationStr += "${duration.hour}h";
    durationStr += "${duration.minute}min";

    List<Widget> listInfo = [
      ListTile(
        leading: const Icon(OMIcons.accessTime),
        title: Text('$timeStart  –  $timeEnd'),
        subtitle: Text(date),
      ),
      ListTile(
        leading: const Icon(OMIcons.timelapse),
        title: Text(durationStr),
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
        title: Text(_course.location),
      ));

    if (_course.isExam())
      listInfo.add(ListTile(
        leading: const Icon(OMIcons.description),
        title: Text(translation(StrKey.COURSE_TEST)),
      ));

    if (_course.color != null)
      listInfo.add(ListTile(
        leading: const Icon(OMIcons.colorLens),
        title: Text(translation(StrKey.EVENT_COLOR)),
        trailing: CircleColor(color: _course.color, circleSize: 28.0),
      ));

    listInfo.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 4.0, 0.0, 8.0),
          child: Text(
            translation(StrKey.NOTES),
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
          ),
        ),
        AddNoteButton(onPressed: _openAddNote)
      ],
    ));
    listInfo.addAll(_buildListNotes());

    return listInfo;
  }

  List<Widget> _buildListNotes() {
    return _course.notes
        .map((note) => CourseNote(note: note, onDelete: _onNoteDeleted))
        .toList();
  }

  void _onNoteDeleted(Note note) {
    setState(() {
      _course.notes.remove(note);
    });
    prefs.removeNote(note);
  }

  void _openAddNote() async {
    var formContent = Form(
      key: _formKey,
      child: TextFormField(
        maxLength: 350,
        maxLines: 6,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: translation(StrKey.ADD_NOTE_PLACEHOLDER),
        ),
        validator: (val) =>
            (val.trim().isEmpty) ? translation(StrKey.ADD_NOTE_EMPTY) : null,
        onSaved: (val) => _noteToAdd = val.trim(),
      ),
    );

    bool isDialogPositive = await DialogPredefined.showContentDialog(
      context,
      translation(StrKey.ADD_NOTE),
      formContent,
      translation(StrKey.ADD_NOTE_SUBMIT),
      translation(StrKey.CANCEL),
    );

    if (isDialogPositive) _submitAddNote();
  }

  void _submitAddNote() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();

      DateTime dateEndNote = _course.dateEnd;
      if (_course is CustomCourse &&
          (_course as CustomCourse).isRecurrentEvent()) {
        dateEndNote = null;
      }
      final note = Note(
        courseUid: _course.uid,
        text: _noteToAdd,
        dateEnd: dateEndNote,
      );

      _noteToAdd = "";
      setState(() {
        _course.notes.insert(0, note);
      });

      prefs.addNote(note, true);
    }
  }

  void _onMenuChoose(CourseMenuItem choice) async {
    bool isHide = choice == CourseMenuItem.HIDE;
    if (isHide || choice == CourseMenuItem.UNHIDE) {
      bool isDialogOk = await DialogPredefined.showTextDialog(
        context,
        translation(isHide ? StrKey.HIDE_EVENT : StrKey.UNHIDE_EVENT),
        translation(isHide ? StrKey.HIDE_EVENT_TEXT : StrKey.UNHIDE_EVENT_TEXT),
        translation(StrKey.YES),
        translation(StrKey.NO),
      );
      if (isDialogOk) {
        if (isHide) {
          prefs.addHiddenEvent(widget.course.title);
        } else {
          prefs.removeHiddenEvent(widget.course.title);
        }
        setState(() {});
      }
    }

    if (choice == CourseMenuItem.EDIT) {
      CustomCourse editedCourse = await Navigator.of(context).push(
        CustomRoute<CustomCourse>(
          builder: (context) => CustomEventScreen(course: _course),
          fullscreenDialog: true,
        ),
      );
      if (editedCourse != null) {
        prefs.editCustomEvent(editedCourse, true);
        setState(() => _course = editedCourse);
      }
    }
    if (choice == CourseMenuItem.DELETE) {
      bool isConfirm = await DialogPredefined.showDeleteEventConfirm(context);
      if (isConfirm) {
        prefs.removeCustomEvent(_course, true);
        Navigator.of(context).pop();
      }
    }
  }

  PopupMenuItem<T> _buildMenu<T>(T value, IconData icon, String title) {
    return PopupMenuItem<T>(
      value: value,
      child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Icon(icon),
        const SizedBox(width: 24.0),
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)
      ]),
    );
  }

  List<Widget> _buildAppbarAction() {
    List<PopupMenuEntry<CourseMenuItem>> actions = [];
    bool isHidden = prefs.isCourseHidden(widget.course);
    actions.add(
      _buildMenu<CourseMenuItem>(
        isHidden ? CourseMenuItem.UNHIDE : CourseMenuItem.HIDE,
        isHidden ? OMIcons.visibility : OMIcons.visibilityOff,
        translation(isHidden ? StrKey.UNHIDE : StrKey.HIDE),
      ),
    );

    if (_course is CustomCourse) {
      actions.addAll([
        _buildMenu<CourseMenuItem>(
          CourseMenuItem.EDIT,
          OMIcons.edit,
          translation(StrKey.EDIT),
        ),
        _buildMenu<CourseMenuItem>(
          CourseMenuItem.DELETE,
          OMIcons.delete,
          translation(StrKey.DELETE),
        )
      ]);
    }

    return [
      PopupMenuButton<CourseMenuItem>(
        icon: const Icon(OMIcons.moreVert),
        onSelected: _onMenuChoose,
        itemBuilder: (_) => actions,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = theme.primaryTextTheme.title.copyWith(fontSize: 17.0);

    return AppbarPage(
      title: translation(StrKey.COURSE_DETAILS),
      actions: _buildAppbarAction(),
      body: Container(
        child: Column(
          children: [
            AppbarSubTitle(child: Text(_course.title, style: textStyle)),
            Expanded(
              child: ListView(shrinkWrap: true, children: _buildInfo()),
            ),
          ],
        ),
      ),
    );
  }
}

enum CourseMenuItem { EDIT, HIDE, UNHIDE, DELETE }
