import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univagenda/keys/pref_key.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/models/courses/course.dart';
import 'package:univagenda/models/courses/custom_course.dart';
import 'package:univagenda/screens/detail_course/detail_course.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';

class CourseRow extends StatelessWidget {
  final Course course;
  final Color noteColor;

  CourseRow({
    Key? key,
    required this.course,
    this.noteColor = PrefKey.defaultNoteColor,
  }) : super(key: key);

  void _onCourseTap(BuildContext context) {
    navigatorPush(
      context,
      DetailCourse(course: course),
      fullscreenDialog: true,
    );
  }

  void _onCustomCourseLong(BuildContext context) async {
    final prefs = context.read<SettingsProvider>();
    bool isConfirm = await DialogPredefined.showDeleteEventConfirm(context);
    if (isConfirm) prefs.removeCustomEvent(course as CustomCourse, true);
  }

  Widget _text(String text, TextStyle style, double size,
      [FontWeight? weight]) {
    return Text(
      text,
      style: style.copyWith(fontSize: size, fontWeight: weight),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<SettingsProvider>();

    Color? bgColorRow = course.getBgColor(prefs.isGenerateEventColor);
    String courseDate = course.dateForDisplay();
    if (course.isStarted()) courseDate += " - ${i18n.text(StrKey.IN_PROGRESS)}";

    final style = TextStyle(color: course.getTitleColor(prefs.isGenerateEventColor));

    String subtitle = course.location ?? '';
    // Location and description not empty
    if (subtitle.isNotEmpty && course.description.isNotEmpty) subtitle += " - ";
    subtitle += course.description;

    return Card(
      elevation: course.isStarted() ? 4.0 : 2.0,
      color: bgColorRow,
      margin: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 10.0),
      child: InkWell(
        onTap: () => _onCourseTap(context),
        onLongPress: () {
          if (course is CustomCourse) {
            _onCustomCourseLong(context);
          } else {
            _onCourseTap(context);
          }
        },
        child: course.isHidden
            ? const SizedBox(height: 7.0)
            : Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _text(course.getTitle(), style, 15, FontWeight.w600),
                          const SizedBox(height: 3.0),
                          _text(subtitle, style, 14.0),
                          const SizedBox(height: 5.0),
                          _text(courseDate, style, 14.0),
                        ],
                      ),
                    ),
                    course.hasNote()
                        ? NoteIndicator(noteColor: noteColor)
                        : const SizedBox(width: 14.0, height: 14.0)
                  ],
                ),
              ),
      ),
    );
  }
}

class NoteIndicator extends StatelessWidget {
  final Color noteColor;

  const NoteIndicator({Key? key, required this.noteColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      shape: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(color: noteColor, shape: BoxShape.circle),
        width: 14.0,
        height: 14.0,
      ),
    );
  }
}
