import 'package:flutter/material.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/widgets/ui/text_oneline.dart';

class DetailCourse extends StatefulWidget {
  final Course cours;

  const DetailCourse({Key key, @required this.cours})
      : assert(cours != null),
        super(key: key);

  @override
  _DetailCourseState createState() => _DetailCourseState();
}

class _DetailCourseState extends State<DetailCourse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Detail course"), elevation: 0.0),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: [
                Expanded(
                    child: Container(
                        color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.cours.title,
                                style:
                                    Theme.of(context).primaryTextTheme.title),
                            TextOneLine(widget.cours.description,
                                style:
                                    Theme.of(context).primaryTextTheme.subhead)
                          ],
                        )))
              ]),
              SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                    Text(widget.cours.title),
                    Text(widget.cours.description)
                  ])),
            ]));
  }
}
