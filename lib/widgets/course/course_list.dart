import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myagenda/data.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
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
  final int numberWeeks;
  final Color noteColor;

  const CourseList(
      {Key key,
      @required this.campus,
      @required this.department,
      @required this.year,
      @required this.group,
      this.numberWeeks = 4,
      this.noteColor})
      : super(key: key);

  @override
  State<CourseList> createState() => CourseListState();
}

class CourseListState extends State<CourseList> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  List<BaseCourse> _listElements;

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

  @protected
  void didUpdateWidget(covariant CourseList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload ical from network
    _fetchData();
  }

  String _prepareURL() {
    final resID = Data
        .getGroupRes(
            widget.campus, widget.department, widget.year, widget.group)
        .toString();
    final nbWeeks = widget.numberWeeks.toString();

    return 'http://edt.univ-lemans.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?projectId=1&calType=ical&nbWeeks=' +
        nbWeeks +
        '&resources=' +
        resID;
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

  void _prepareList(String icalStr) async {
    List<Course> listCourses = [];

    // Get all notes saved (expired notes removed by getNotes())
    List<Note> allNotes = await Preferences.getNotes();

    // Parse string ical to object
    for (final icalModel in Ical.parseToIcal(icalStr)) {
      Course course = Course.fromIcalModel(icalModel);
      // Get all notes of the course, and sort by dateCreation desc
      final courseNotes =
          allNotes.where((note) => note.courseUid == course.uid).toList();
      courseNotes.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));

      // Add all note of a course
      course.notes = courseNotes;

      listCourses.add(course);
    }

    // Sort list by date start (to add headers)
    listCourses.sort((a, b) => a.dateStart.compareTo(b.dateStart));

    // List for all Cours and header
    List<BaseCourse> listElement = [];
    listElement.addAll(listCourses);

    // Init variable to add headers
    DateTime lastDate = DateTime(1970); // Init variable to 1970

    // Add headers to course list
    for (int i = 0; i < listElement.length; i++) {
      if (listElement[i] is Course) {
        final Course course = listElement[i];

        if (Date.notSameDay(course.dateStart, lastDate)) {
          listElement.insert(i, CourseHeader(course.dateStart));
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

    _listElements?.forEach((course) {
      if (course is CourseHeader)
        widgets.add(CourseRowHeader(coursHeader: course));
      else if (course is Course) widgets.add(CourseRow(course: course, noteColor: widget.noteColor));
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView(
            shrinkWrap: true,
            children: ListTile
                .divideTiles(context: context, tiles: _buildListCours())
                .toList()),
        key: refreshKey);
  }
}
