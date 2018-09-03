import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/utils/IcalAPI.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/widgets/course/course_list_header.dart';
import 'package:myagenda/widgets/course/course_row.dart';
import 'package:myagenda/widgets/course/course_row_header.dart';
import 'package:myagenda/widgets/ui/about_card.dart';

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
    _listElements = [];

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

  Future<Null> _fetchData() async {
    if (!mounted) return null;

    refreshKey.currentState?.show();

    final url = IcalAPI.prepareURL(
      widget.campus,
      widget.department,
      widget.year,
      widget.group,
      widget.numberWeeks
    );

    final response = await http.get(url);
    if (response.statusCode == 200 && mounted) {
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

  Course _addNotesToCourse(List<Note> notes, Course course) {
    // Get all note of the course
    final courseNotes =
        notes.where((note) => note.courseUid == course.uid).toList();

    // Sorts notes by date desc
    courseNotes.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));

    // Add notes to the course
    course.notes = courseNotes;

    return course;
  }

  void _prepareList(String icalStr) async {
    List<Course> listCourses = [];

    // Get all notes saved (expired notes removed by getNotes())
    List<Note> allNotes = await Preferences.getNotes();

    // Get all custom events (except expired)
    List<Course> customEvents = await Preferences.getCustomEvents();

    // Add custom courses with their notes to list
    for (final course in customEvents) {
      listCourses.add(_addNotesToCourse(allNotes, course));
    }

    // Parse string ical to object
    for (final icalModel in Ical.parseToIcal(icalStr)) {
      // Transform IcalModel to Course
      Course course = Course.fromIcalModel(icalModel);

      // Get all notes of the course
      course = _addNotesToCourse(allNotes, course);

      // Add course to list
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

    if (mounted)
      setState(() {
        _listElements = listElement;
      });
  }

  Widget _buildListCours() {
    List<Widget> widgets = [
      CourseListHeader(year: widget.year, group: widget.group)
    ];

    if (_listElements.length == 0) {
      widgets.add(AboutCard(
        title: "Aucun cours",
        children: <Widget>[
          Text("Essayez de modifier le nombre de semaines à afficher.",
              textAlign: TextAlign.justify)
        ],
      ));
    } else {
      _listElements.forEach((course) {
        if (course is CourseHeader)
          widgets.add(CourseRowHeader(coursHeader: course));
        else if (course is Course)
          widgets.add(CourseRow(course: course, noteColor: widget.noteColor));
      });
    }

    return ListView(
        children: ListTile
            .divideTiles(context: context, tiles: widgets)
            .toList(growable: false));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: refreshKey,
      onRefresh: _fetchData,
      child: _buildListCours(),
    );
  }
}
