import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myagenda/models/course.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/widgets/course/course_list_header.dart';
import 'package:myagenda/widgets/course/course_row.dart';
import 'package:myagenda/widgets/course/course_row_header.dart';

class CourseList extends StatefulWidget {
  final String campus;
  final String department;
  final String year;
  final String group;

  const CourseList(
      {Key key,
      @required this.campus,
      @required this.department,
      @required this.year,
      @required this.group})
      : super(key: key);

  @override
  State<CourseList> createState() => CourseListState();
}

class CourseListState extends State<CourseList> {
  List<BaseCourse> _listElements = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Load cached ical
    _loadIcalCached().then((ical) {
      if (ical != null && ical.isNotEmpty) _prepareList(ical);
    });

    // Load ical from network
    _fetchData();
  }

  String _prepareURL() {
    return 'https://pastebin.com/raw/Mnjd86L1';
  }

  Future<Null> _fetchData() async {
    refreshKey.currentState?.show();

    final response = await http.get(_prepareURL());
    if (response.statusCode == 200) {
      _prepareList(response.body);
      _updateCache(response.body);
    } else {
      // TODO: Afficher message d'erreur
    }
    return null;
  }

  void _updateCache(String ical) async {
    Preferences.setCachedIcal(ical);
  }

  Future<String> _loadIcalCached() async {
    return await Preferences.getCachedIcal();
  }

  void _prepareList(String icalStr) {
    List<Course> listCourses = [];

    // Parse string ical to object
    Ical.parseToIcal(icalStr).forEach((icalModel) {
      listCourses.add(Course.fromIcalModel(icalModel));
    });

    // Sort list by date start
    listCourses
        .sort((Course a, Course b) => a.dateStart.compareTo(b.dateStart));

    // List for all Cours and header
    List<BaseCourse> listElement = [];
    listElement.addAll(listCourses);

    // Init variable to add headers
    DateTime lastDate = DateTime(1970); // Init variable to 1970
    int listSize = listElement.length;

    // Add header to list
    for (int i = 0; i < listSize; i++) {
      if (listElement[i] is Course) {
        final Course course = listElement[i];

        if (Date.notSameDay(course.dateStart, lastDate)) {
          listElement.insert(i, CourseHeader(course.dateStart));
          listSize++;
          lastDate = course.dateStart;
        }
      }
    }

    setState(() {
      _listElements = listElement;
    });
  }

  List<Widget> _buildListCours() {
    List<Widget> widgets = [];

    widgets.add(CourseListHeader(year: widget.year, group: widget.group));

    _listElements.forEach((course) {
      if (course is CourseHeader)
        widgets.add(CourseRowHeader(coursHeader: course));
      else if (course is Course) widgets.add(CourseRow(course: course));
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final dividedWidgetList = ListTile
        .divideTiles(context: context, tiles: _buildListCours())
        .toList();

    return RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView(shrinkWrap: true, children: dividedWidgetList),
        key: refreshKey);
  }
}
