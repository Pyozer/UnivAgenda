import 'package:flutter/material.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/widgets/ui/text_oneline.dart';

class DetailCourse extends StatefulWidget {
  final Course course;

  const DetailCourse({Key key, @required this.course})
      : assert(course != null),
        super(key: key);

  @override
  _DetailCourseState createState() => _DetailCourseState();
}

class _DetailCourseState extends State<DetailCourse> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(title: Text("Detail course"), elevation: 0.0),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: [
                Expanded(
                    child: Container(
                        color: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 24.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.course.title,
                                  style: theme.primaryTextTheme.title),
                              TextOneLine(widget.course.description,
                                  style: theme.primaryTextTheme.subhead)
                            ])))
              ]),
              SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(widget.course.title),
                    Text(widget.course.description)
                  ]))
            ]));
  }
}
