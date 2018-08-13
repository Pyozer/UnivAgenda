import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myagenda/models/cours.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/widgets/cours/cours_list_header.dart';
import 'package:myagenda/widgets/cours/cours_row.dart';
import 'package:myagenda/widgets/cours/cours_row_header.dart';

class CoursList extends StatefulWidget {
  final String campus;
  final String department;
  final String year;
  final String group;

  const CoursList(
      {Key key,
      @required this.campus,
      @required this.department,
      @required this.year,
      @required this.group})
      : super(key: key);

  @override
  State<CoursList> createState() => new CoursListState();
}

class CoursListState extends State<CoursList> {
  List<BaseCours> _listElements = [];
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
    List<Cours> listCours = [];

    // Parse string ical to object
    Ical.parseToIcal(icalStr).forEach((icalModel) {
      listCours.add(Cours.fromIcalModel(icalModel));
    });

    // Sort list by date start
    listCours.sort((Cours a, Cours b) => a.dateStart.compareTo(b.dateStart));

    // List for all Cours and header
    List<BaseCours> listElement = [];
    listElement.addAll(listCours);

    // Init variable to add headers
    DateTime lastDate = DateTime(1970); // Init variable to 1970
    int listSize = listElement.length;

    // Add header to list
    for (int i = 0; i < listSize; i++) {
      if (listElement[i] is Cours) {
        final Cours cours = listElement[i];

        if (Date.notSameDay(cours.dateStart, lastDate)) {
          listElement.insert(i, CoursHeader(cours.dateStart));
          listSize++;
          lastDate = cours.dateStart;
        }
      }
    }

    setState(() {
      _listElements = listElement;
    });
  }

  List<Widget> _buildListCours() {
    List<Widget> widgets = [];

    widgets.add(CoursListHeader(year: widget.year, group: widget.group));

    _listElements.forEach((cours) {
      if (cours is CoursHeader)
        widgets.add(CoursRowHeader(coursHeader: cours));
      else if (cours is Cours) widgets.add(CoursRow(cours: cours));
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
