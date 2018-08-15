import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/translations.dart';

class DetailCourse extends StatefulWidget {
  final Course course;

  const DetailCourse({Key key, @required this.course})
      : assert(course != null),
        super(key: key);

  @override
  _DetailCourseState createState() => _DetailCourseState();
}

class _DetailCourseState extends State<DetailCourse> {
  List<Widget> _buildInfo(Translations translate) {
    final locale = translate.locale;

    final timeStart = Date.extractTime(widget.course.dateStart, locale);
    final timeEnd = Date.extractTime(widget.course.dateEnd, locale);
    final date = Date.extractDate(widget.course.dateStart, locale);

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

    listInfo.add(ListTile(
        leading: Icon(Icons.attach_file), title: Text(widget.course.uid)));

    return listInfo;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translations.of(context);

    return AppbarPage(
        title: translate.get(StringKey.COURSE_DETAILS),
        elevation: 0.0,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Material(
                    color: theme.primaryColor,
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 16.0),
                      child: Text(widget.course.title,
                          style: theme.primaryTextTheme.title),
                    )))
          ]),
          SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildInfo(translate)))
        ]));
  }
}
