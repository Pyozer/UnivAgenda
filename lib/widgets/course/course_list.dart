import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/course.dart';
import 'package:myagenda/models/note.dart';
import 'package:myagenda/utils/ical_api.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
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
  final bool isHorizontal;
  final Color noteColor;

  const CourseList(
      {Key key,
      @required this.campus,
      @required this.department,
      @required this.year,
      @required this.group,
      this.numberWeeks = 4,
      this.isHorizontal = false,
      this.noteColor})
      : super(key: key);

  @override
  State<CourseList> createState() => CourseListState();
}

class CourseListState extends State<CourseList> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Map<DateTime, List<BaseCourse>> _listElements = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _listElements = {};

    // Load cached ical
    PreferencesProvider.of(context).prefs.getCachedIcal().then((ical) {
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
    print("fetch data");
    final url = IcalAPI.prepareURL(widget.campus, widget.department,
        widget.year, widget.group, widget.numberWeeks);

    final response = await http.get(url);
    if (response.statusCode == 200 && mounted) {
      await _prepareList(response.body);
      _updateCache(response.body);
    } else {
      // TODO: Afficher message d'erreur
    }
    return null;
  }

  void _updateCache(String ical) async {
    PreferencesProvider.of(context).prefs.setCachedIcal(ical);
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

  Future<Null> _prepareList(String icalStr) async {
    List<Course> listCourses = [];

    final prefs = PreferencesProvider.of(context).prefs;

    // Get all notes saved (expired notes removed by getNotes())
    List<Note> allNotes = await prefs.getNotes();

    // Get all custom events (except expired)
    List<Course> customEvents = await prefs.getCustomEvents();

    // Add custom courses with their notes to list
    for (final course in customEvents) {
      listCourses.add(_addNotesToCourse(allNotes, course));
    }

    // Parse string ical to object
    for (final icalModel in Ical.parseToIcal(icalStr)) {
      // Transform IcalModel to Course
      Course course = Course.fromIcalModel(icalModel);
      // Check if course is not finish
      if (!course.isFinish()) {
        // Get all notes of the course
        course = _addNotesToCourse(allNotes, course);

        // Add course to list
        listCourses.add(course);
      }
    }

    // Sort list by date start (to add headers)
    listCourses.sort((a, b) => a.dateStart.compareTo(b.dateStart));

    // List for all Cours and header
    Map<DateTime, List<BaseCourse>> listElement = {};
    //listElement.addAll(listCourses);

    // Init variable to add headers
    DateTime lastDate = DateTime(1970); // Init variable to 1970

    // Add headers to course list
    List<BaseCourse> listCourseDay = [];
    for (int i = 0; i < listCourses.length; i++) {
      if (listCourses[i] is Course) {
        final Course course = listCourses[i];

        if (Date.notSameDay(course.dateStart, lastDate)) {
          if (i != 0) {
            listElement[lastDate] = listCourseDay;
            listCourseDay = [];
          }
          lastDate = course.dateStart;
        }

        listCourseDay.add(course);
      }
    }

    if (mounted) {
      setState(() {
        _listElements = listElement;
      });
    }
    return null;
  }

  Widget _buildListCours(List<BaseCourse> courses) {
    List<Widget> widgets = [];

    if (courses != null) {
      if (courses.length == 0) {
        widgets.add(AboutCard(
          title: Translations.of(context).get(StringKey.COURSES_NORESULT),
          children: <Widget>[
            Text(
              Translations.of(context).get(StringKey.COURSES_NORESULT_TEXT),
              textAlign: TextAlign.justify,
            ),
          ],
        ));
      } else {
        courses.forEach((course) {
          if (course is CourseHeader)
            widgets.add(CourseRowHeader(coursHeader: course));
          else if (course is Course)
            widgets.add(CourseRow(course: course, noteColor: widget.noteColor));
        });
      }
    }

    return ListView(
      children: widgets
    );
  }

  Widget _buildHorizontal(Map<DateTime, List<BaseCourse>> elements) {
    if (elements.length < 1) {
      return Container();
    }

    final langCode = Translations.of(context).locale.languageCode;
    final textTheme = Theme.of(context).textTheme;
    List<Widget> listTabView = [];
    List<Widget> tabs = [];
    // Build horizontal view
    elements.forEach((date, courses) {
      tabs.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Text(
            DateFormat.MEd(langCode).format(date),
            style: textTheme.title,
          ),
        ),
      );

      listTabView.add(
        _buildListCours(courses),
      );
    });

    return DefaultTabController(
      length: elements.length,
      child: Column(children: [
        TabBar(
          isScrollable: true,
          tabs: tabs,
        ),
        Expanded(
          child: TabBarView(
            children: listTabView,
          ),
        ),
      ]),
    );
  }

  Widget _buildVertical(Map<DateTime, List<BaseCourse>> elements) {
    // Build vertical view
    final List<BaseCourse> listChildren = [];
    elements.forEach((date, courses) {
      listChildren.add(CourseHeader(date));
      listChildren.addAll(courses);
    });

    return _buildListCours(listChildren);
  }

  @override
  Widget build(BuildContext context) {
    final isHorizontal = widget.isHorizontal;

    print("dsfsdssd");

    return RefreshIndicator(
      key: refreshKey,
      onRefresh: _fetchData,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          CourseListHeader(year: widget.year, group: widget.group),
          Divider(height: 0.0),
          Expanded(
            child: Container(
              child: (isHorizontal)
                  ? _buildHorizontal(_listElements)
                  : _buildVertical(_listElements),
            ),
          ),
        ],
      ),
    );
  }
}
