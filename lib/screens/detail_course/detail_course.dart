import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/models/courses/custom_course.dart';
import 'package:univagenda/models/courses/note.dart';
import 'package:univagenda/screens/appbar_screen.dart';
import 'package:univagenda/screens/base_state.dart';
import 'package:univagenda/screens/custom_event/custom_event.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/custom_route.dart';
import 'package:univagenda/utils/date.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/course_note/add_note_button.dart';
import 'package:univagenda/widgets/course_note/course_note.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:outline_material_icons_tv/outline_material_icons.dart';

enum MenuItem { EDIT, HIDE, UNHIDE, DELETE, RENAME }

class DetailCourse extends StatefulWidget {
  final Course course;

  const DetailCourse({Key? key, required this.course}) : super(key: key);

  @override
  _DetailCourseState createState() => _DetailCourseState();
}

class _DetailCourseState extends BaseState<DetailCourse> {
  final _formKey = GlobalKey<FormState>();
  late String _noteToAdd;
  late Course _course;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
    AnalyticsProvider.setScreen(widget);
  }

  List<Widget> _buildInfo() {
    final timeStart = Date.extractTime(_course.dateStart);
    final timeEnd = Date.extractTime(_course.dateEnd);
    final date = Date.dateFromNow(_course.dateStart);

    final duration = Date.calculateDuration(_course.dateStart, _course.dateEnd);
    String durationStr = "";
    if (duration.hour > 0) durationStr += "${duration.hour}h";
    durationStr += "${duration.minute}min";

    return <Widget>[
      ListTile(
        leading: const Icon(OMIcons.accessTime),
        title: Text('$timeStart  –  $timeEnd'),
        subtitle: Text(date),
      ),
      ListTile(
        leading: const Icon(OMIcons.timelapse),
        title: Text(durationStr),
      ),
      if (_course.description.isNotEmpty)
        ListTile(
          leading: const Icon(OMIcons.group),
          title: Text(
            _course.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      if (_course.location?.isNotEmpty ?? false)
        ListTile(
          leading: const Icon(OMIcons.locationOn),
          title: Text(_course.location!),
        ),
      if (_course.isExam())
        ListTile(
          leading: const Icon(OMIcons.description),
          title: Text(i18n.text(StrKey.COURSE_TEST)),
        ),
      if (_course.color != null)
        ListTile(
          leading: const Icon(OMIcons.colorLens),
          title: Text(i18n.text(StrKey.EVENT_COLOR)),
          trailing: CircleColor(color: _course.color!, circleSize: 28.0),
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 0.0, 8.0),
            child: Text(
              i18n.text(StrKey.NOTES),
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
            ),
          ),
          AddNoteButton(onPressed: _openAddNote)
        ],
      ),
      ..._buildListNotes()
    ];
  }

  List<Widget> _buildListNotes() {
    return _course.notes
        .map((note) => CourseNote(note: note, onDelete: _onNoteDeleted))
        .toList();
  }

  void _onNoteDeleted(Note note) {
    setState(() => _course.notes.remove(note));
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
          hintText: i18n.text(StrKey.ADD_NOTE_PLACEHOLDER),
        ),
        validator: (value) {
          return (value?.trim().isEmpty ?? true)
              ? i18n.text(StrKey.ADD_NOTE_EMPTY)
              : null;
        },
        onSaved: (val) => _noteToAdd = val?.trim() ?? '',
      ),
    );

    bool isDialogPositive = await DialogPredefined.showContentDialog(
      context,
      i18n.text(StrKey.ADD_NOTE),
      formContent,
      i18n.text(StrKey.ADD_NOTE_SUBMIT),
      i18n.text(StrKey.CANCEL),
    );

    if (isDialogPositive) _submitAddNote();
  }

  Future<String?> _openRenameDialog([String currentValue = ""]) async {
    String inputValue = currentValue;
    final formContent = TextField(
      controller: TextEditingController(text: currentValue),
      maxLength: 60,
      maxLines: null,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: i18n.text(StrKey.NEW_EVENT_TITLE),
      ),
      onChanged: (value) => inputValue = value,
    );

    bool? isDialogPositive = await DialogPredefined.showContentDialog(
      context,
      i18n.text(StrKey.RENAME_EVENT),
      formContent,
      i18n.text(StrKey.RENAME),
      i18n.text(StrKey.CANCEL),
    );
    return isDialogPositive ? inputValue : null;
  }

  void _submitAddNote() {
    final form = _formKey.currentState;

    if (form?.validate() ?? false) {
      form!.save();
      final note = Note(courseUid: _course.uid, text: _noteToAdd);
      _noteToAdd = "";
      setState(() => _course.notes.insert(0, note));
      prefs.addNote(note);
    }
  }

  void _onMenuChoose(MenuItem choice) async {
    if (choice == MenuItem.HIDE || choice == MenuItem.UNHIDE) {
      bool isHide = choice == MenuItem.HIDE;
      bool isDialogOk = await DialogPredefined.showTextDialog(
        context,
        i18n.text(isHide ? StrKey.HIDE_EVENT : StrKey.UNHIDE_EVENT),
        i18n.text(isHide ? StrKey.HIDE_EVENT_TEXT : StrKey.UNHIDE_EVENT_TEXT),
        i18n.text(StrKey.YES),
        i18n.text(StrKey.NO),
      );
      if (!isDialogOk) {
        return;
      }
      if (isHide) {
        prefs.addHiddenEvent(widget.course.title);
      } else {
        prefs.removeHiddenEvent(widget.course.title);
      }
      setState(() {});
    } else if (choice == MenuItem.EDIT) { // Only for CustomCourse
      CustomCourse? editedCourse = await Navigator.of(context).push(
        CustomRoute<CustomCourse>(
          builder: (context) => CustomEventScreen(course: _course as CustomCourse),
          fullscreenDialog: true,
        ),
      );
      if (editedCourse != null) {
        setState(() => _course = editedCourse);
        prefs.editCustomEvent(editedCourse, true);
      }
    } else if (choice == MenuItem.DELETE) { // Only for CustomCourse
      bool isConfirm = await DialogPredefined.showDeleteEventConfirm(context);
      if (isConfirm) {
        prefs.removeCustomEvent(_course as CustomCourse, true);
        Navigator.of(context).pop();
      }
    } else if (choice == MenuItem.RENAME) {
      String? rename = await _openRenameDialog(widget.course.getTitle());
      if (rename != null) {
        if (rename.isNotEmpty) {
          widget.course.renamedTitle = rename;
          prefs.addRenamedEvent(widget.course.title, rename);
        } else {
          widget.course.renamedTitle = null;
          prefs.removeRenamedEvent(widget.course.title);
        }
        setState(() {});
      }
    }
  }

  PopupMenuItem<MenuItem> _item(MenuItem value, IconData icon, String title) {
    return PopupMenuItem<MenuItem>(
      value: value,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  List<Widget> _buildAppbarAction() {
    bool isHidden = prefs.isCourseHidden(widget.course);

    List<PopupMenuEntry<MenuItem>> actions = [
      _item(
        isHidden ? MenuItem.UNHIDE : MenuItem.HIDE,
        isHidden ? OMIcons.visibility : OMIcons.visibilityOff,
        i18n.text(isHidden ? StrKey.UNHIDE : StrKey.HIDE),
      ),
      _item(MenuItem.RENAME, OMIcons.title, i18n.text(StrKey.RENAME)),
      if (_course is CustomCourse) ...[
        _item(MenuItem.EDIT, OMIcons.edit, i18n.text(StrKey.EDIT)),
        _item(MenuItem.DELETE, OMIcons.delete, i18n.text(StrKey.DELETE))
      ],
    ];

    return [
      PopupMenuButton<MenuItem>(
        icon: const Icon(OMIcons.moreVert),
        onSelected: _onMenuChoose,
        itemBuilder: (_) => actions,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        theme.primaryTextTheme.headline6!.copyWith(fontSize: 17.0);

    return AppbarPage(
      title: i18n.text(StrKey.COURSE_DETAILS),
      actions: _buildAppbarAction(),
      body: Container(
        child: Column(
          children: [
            AppbarSubTitle(child: Text(_course.getTitle(), style: textStyle)),
            Expanded(child: ListView(shrinkWrap: true, children: _buildInfo())),
          ],
        ),
      ),
    );
  }
}
