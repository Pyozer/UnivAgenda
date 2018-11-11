import 'package:flutter/material.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/models/courses/custom_course.dart';
import 'package:myagenda/screens/detail_course/detail_course.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';

class CourseRow extends StatelessWidget {
  final Course course;
  final Color noteColor;

  CourseRow(
      {Key key,
      this.course,
      this.noteColor = const Color(PrefKey.defaultNoteColor)})
      : super(key: key);

  void _onCourseTap(BuildContext context) {
    Navigator.of(context).push(
      CustomRoute<Course>(
        builder: (context) => DetailCourse(course: course),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = PreferencesProvider.of(context);

    Color bgColorRow;
    if (course.color != null)
      bgColorRow = course.color;
    else if (course.isExam())
      bgColorRow = Colors.red[600];
    else if (prefs.isGenerateEventColor)
      bgColorRow = getColorFromString(course.titleClear());

    String courseDate = course.dateForDisplay();
    if (course.isStarted()) {
      courseDate += " - ${Translations.of(context).get(StringKey.IN_PROGRESS)}";
    }

    TextStyle textStyle = TextStyle();

    if (bgColorRow != null) {
      var bgBrightness = ThemeData.estimateBrightnessForColor(bgColorRow);
      bool isBgDark = isDarkTheme(bgBrightness);

      textStyle =
          textStyle.copyWith(color: isBgDark ? Colors.white : Colors.black);
    }

    var subtitle = course.location;
    // Location and description not empty
    if (subtitle.length > 0 && course.description.length > 0)
      subtitle += " - ";
    subtitle += course.description;

    return Card(
      elevation: course.isStarted() ? 4.0 : 3.0,
      color: bgColorRow,
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: InkWell(
        onTap: () => _onCourseTap(context),
        onLongPress: () async {
          if (course is CustomCourse) {
            bool isConfirm =
                await DialogPredefined.showDeleteEventConfirm(context);
            if (isConfirm) prefs.removeCustomEvent(course, true);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      course.title,
                      style: textStyle.copyWith(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: textStyle.copyWith(fontSize: 14.0),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      courseDate,
                      style: textStyle.copyWith(fontSize: 14.0),
                    )
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

  const NoteIndicator({Key key, this.noteColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      shape: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          color: noteColor,
          shape: BoxShape.circle,
        ),
        width: 14.0,
        height: 14.0,
      ),
    );
  }
}
