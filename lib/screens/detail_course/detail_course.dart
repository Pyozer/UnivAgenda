import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

import '../../keys/string_key.dart';
import '../../models/courses/course.dart';
import '../../models/courses/custom_course.dart';
import '../../models/courses/hidden.dart';
import '../../models/courses/note.dart';
import '../appbar_screen.dart';
import '../custom_event/custom_event.dart';
import '../../utils/analytics.dart';
import '../../utils/date.dart';
import '../../utils/functions.dart';
import '../../utils/preferences/settings.provider.dart';
import '../../utils/translations.dart';
import '../../widgets/course_note/course_note.dart';
import '../../widgets/ui/dialog/dialog_predefined.dart';

enum MenuItem { EDIT, HIDE, UNHIDE, DELETE, RENAME }

class DetailCourse extends StatefulWidget {
  final Course course;

  const DetailCourse({Key? key, required this.course}) : super(key: key);

  @override
  DetailCourseState createState() => DetailCourseState();
}

class DetailCourseState extends State<DetailCourse> {
  late Course _course;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
    AnalyticsProvider.setScreen(widget);
  }

  List<Widget> _buildInfo() {
    final startDate = Date.dateFromNow(_course.dateStart);
    final startTime = Date.extractTime(context, _course.dateStart);
    final endDate = Date.dateFromNow(_course.dateEndCalc);
    final endTime = Date.extractTime(context, _course.dateEnd);
    final duration = Date.calculateDuration(_course.dateStart, _course.dateEnd);

    List<String> durations = [];
    if (duration.hour >= 24) {
      durations.add(i18n.text(StrKey.DAY, {'value': duration.hour ~/ 24}));
    }
    if (duration.hour % 24 > 0) {
      durations.add(i18n.text(StrKey.HOUR, {'value': duration.hour % 24}));
    }
    if (duration.minute > 0) {
      durations.add(i18n.text(StrKey.MINUTE, {'value': duration.minute}));
    }

    Widget buildDate() {
      if (_course.isAllDayOnlyOneDay()) {
        return ListTile(
          leading: const Icon(Icons.access_time),
          title: Text(startDate),
        );
      }
      if (_course.isAllDay()) {
        return ListTile(
          leading: const Icon(Icons.access_time),
          title: Text('$startDate - $endDate'),
        );
      }
      if (startDate == endDate) {
        return ListTile(
          leading: const Icon(Icons.access_time),
          title: Text('$startTime - $endTime'),
          subtitle: Text(startDate),
        );
      }
      return ListTile(
        leading: const Icon(Icons.access_time),
        title: Text('$startDate à $startTime - '),
        subtitle: Text('$endDate à $endTime'),
        subtitleTextStyle: Theme.of(context).textTheme.bodyLarge,
      );
    }

    return <Widget>[
      buildDate(),
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
      const SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              i18n.text(StrKey.NOTES),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(i18n.text(StrKey.ADD_NOTE_BTN)),
              onPressed: () => _openNoteDialog(),
            ),
          ],
        ),
      ),
      ..._course.allNotes.map((note) => CourseNote(
            note: note,
            onDelete: _onNoteDeleted,
            onEdit: _openNoteDialog,
          ))
    ];
  }

  void _onNoteDeleted(Note note) {
    setState(() => _course.allNotes.remove(note));
    context.read<SettingsProvider>().removeNote(note, true);
  }

  void _openNoteDialog([Note? note]) async {
    final noteController = TextEditingController(text: note?.text ?? '');

    final formContent = Form(
      child: TextFormField(
        controller: noteController,
        maxLength: 350,
        maxLines: 6,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: i18n.text(StrKey.ADD_NOTE_PLACEHOLDER),
        ),
      ),
    );

    bool isDialogPositive = await DialogPredefined.showContentDialog(
      context,
      i18n.text(
        note == null ? StrKey.ADD_NOTE : StrKey.EDIT_NOTE,
      ),
      formContent,
      i18n.text(
        note == null ? StrKey.ADD_NOTE_SUBMIT : StrKey.EDIT_NOTE_SUBMIT,
      ),
      i18n.text(StrKey.CANCEL),
    );

    if (!mounted) return;
    if (!isDialogPositive) return;

    final noteText = noteController.value.text.trim();
    if (noteText.isEmpty) return;

    if (note != null) {
      setState(() => note.text = noteText);
      context.read<SettingsProvider>().setNotes(_course.allNotes);
    } else {
      final newNote = Note(courseUid: _course.uid, text: noteText);
      setState(() => _course.allNotes.insert(0, newNote));
      context.read<SettingsProvider>().addNote(newNote, true);
    }
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
          Hidden(courseUid: widget.course.uid, title: widget.course.title),
        );
      } else {
        prefs.removeHiddenEvent(widget.course.uid);
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
