import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/models/courses/custom_course.dart';
import 'package:univagenda/models/courses/hidden.dart';
import 'package:univagenda/models/courses/note.dart';
import 'package:univagenda/screens/appbar_screen.dart';
import 'package:univagenda/screens/custom_event/custom_event.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/date.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/course_note/add_note_button.dart';
import 'package:univagenda/widgets/course_note/course_note.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';

enum MenuItem { EDIT, HIDE, UNHIDE, DELETE, RENAME }

class DetailCourse extends StatefulWidget {
  final Course course;

  const DetailCourse({Key? key, required this.course}) : super(key: key);

  @override
  DetailCourseState createState() => DetailCourseState();
}

class DetailCourseState extends State<DetailCourse> {
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
    final startTime = Date.extractTime(_course.dateStart);
    final endTime = Date.extractTime(_course.dateEnd);
    final startDate = Date.dateFromNow(_course.dateStart);
    final endDate = Date.dateFromNow(_course.dateEnd);
    final duration = Date.calculateDuration(_course.dateStart, _course.dateEnd);

    List<String> durations = [];
    // TODO: ADD translation
    if (duration.hour >= 24) durations.add('${duration.hour ~/ 24}j');
    if (duration.hour % 24 > 0) durations.add('${duration.hour % 24}h');
    if (duration.minute > 0) durations.add('${duration.minute}min');

    return <Widget>[
      if (startDate == endDate)
        ListTile(
          leading: const Icon(Icons.access_time),
          title: Text('$startTime - $endTime'),
          subtitle: Text(startDate),
        ),
      if (startDate != endDate)
        ListTile(
          leading: const Icon(Icons.access_time),
          title: Text('$startDate à $startTime - '),
          subtitle: Text('$endDate à $endTime'),
          subtitleTextStyle: Theme.of(context).textTheme.bodyLarge,
        ),
      ListTile(
        leading: const Icon(Icons.timelapse),
        title: Text(durations.join(' ')),
      ),
      if (_course.description.isNotEmpty)
        ListTile(
          leading: const Icon(Icons.group_outlined),
          title: Text(
            _course.description,
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      if (_course.location?.isNotEmpty ?? false)
        ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(
            _course.location!,
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      if (_course.isExam())
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(i18n.text(StrKey.COURSE_TEST)),
        ),
      if (_course.color != null)
        ListTile(
          leading: const Icon(Icons.color_lens_outlined),
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
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AddNoteButton(onPressed: _openAddNote),
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
    context.read<SettingsProvider>().removeNote(note);
  }

  void _openAddNote() async {
    final formContent = Form(
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

  Future<String?> _openRenameDialog([String currentValue = '']) async {
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
      _noteToAdd = '';
      setState(() => _course.notes.insert(0, note));
      context.read<SettingsProvider>().addNote(note);
    }
  }

  void _onMenuChoose(MenuItem choice) async {
    final prefs = context.read<SettingsProvider>();
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
        prefs.addHiddenEvent(
            Hidden(courseUid: widget.course.uid, title: widget.course.title));
      } else {
        prefs.removeHiddenEvent(widget.course.title);
      }
      setState(() {});
    } else if (choice == MenuItem.EDIT) {
      // Only for CustomCourse
      CustomCourse? editedCourse = await navigatorPush(
        context,
        CustomEventScreen(course: _course as CustomCourse),
        fullscreenDialog: true,
      );

      if (editedCourse != null) {
        setState(() => _course = editedCourse);
        prefs.editCustomEvent(editedCourse, true);
      }
    } else if (choice == MenuItem.DELETE) {
      // Only for CustomCourse
      bool isConfirm = await DialogPredefined.showDeleteEventConfirm(context);
      if (isConfirm && mounted) {
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

  List<Widget> _buildAppbarAction(bool isCourseHidden) {
    List<PopupMenuEntry<MenuItem>> actions = [
      _item(
        isCourseHidden ? MenuItem.UNHIDE : MenuItem.HIDE,
        isCourseHidden
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        i18n.text(isCourseHidden ? StrKey.UNHIDE : StrKey.HIDE),
      ),
      _item(MenuItem.RENAME, Icons.title, i18n.text(StrKey.RENAME)),
      if (_course is CustomCourse) ...[
        _item(MenuItem.EDIT, Icons.edit_outlined, i18n.text(StrKey.EDIT)),
        _item(MenuItem.DELETE, Icons.delete_outline, i18n.text(StrKey.DELETE))
      ],
    ];

    return [
      PopupMenuButton<MenuItem>(
        icon: const Icon(Icons.more_vert),
        onSelected: _onMenuChoose,
        itemBuilder: (_) => actions,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: _course.getBgColor(prefs.isGenerateEventColor),
          foregroundColor: _course.getTitleColor(prefs.isGenerateEventColor),
        ),
      ),
      child: AppbarPage(
        title: i18n.text(StrKey.COURSE_DETAILS),
        actions: _buildAppbarAction(prefs.isCourseHidden(widget.course)),
        body: Column(
          children: [
            AppbarSubTitle(
              text: _course.getTitle(),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: _buildInfo(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
