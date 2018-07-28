import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:myagenda/models/Cours.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/ical.dart';

class CoursList extends StatefulWidget {
  final int resId;

  CoursList({Key key, this.resId}) : super(key: key);

  @override
  State<CoursList> createState() => new CoursListState();
}

class CoursListState extends State<CoursList> {
  List<BaseCours> _listElements = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<Null> _fetchData() async {
    refreshKey.currentState?.show(atTop: false);
    final response = await http.get('https://pastebin.com/raw/Mnjd86L1');
    if (response.statusCode == 200)
      setState(() {
        _listElements = prepareList(response.body);
      });
    else
      throw Exception('Failed to load ical');

    return null;
  }

  List<BaseCours> prepareList(String icalStr) {
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

    return listElement;
  }

  Widget _buildRow(int index) {
    final Cours cours = _listElements[index];
    return new CoursRow(cours: cours);
  }

  Widget _buildRowHeader(int index) {
    final CoursHeader header = _listElements[index];

    return Container(
        color: Colors.grey[300],
        padding: const EdgeInsets.all(14.0),
        child: Row(
            children: [
              Expanded(
                  child: Text(
                      header.dateForDisplay(),
                      style: Theme.of(context).textTheme.title
                  )
              )
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (_listElements[index] is CoursHeader) return _buildRowHeader(index);
          /*else if (index.isOdd)
            return new Divider(color: Colors.grey[300]);*/
          else return _buildRow(index);
        },
        itemCount: _listElements.length
      ),
      key: refreshKey
    );
  }
}

class CoursRow extends StatelessWidget {
  final Cours cours;

  const CoursRow({Key key, this.cours}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: cours.isExam() ? Colors.red : Colors.white,
        padding: const EdgeInsets.all(13.0),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Text(cours.title,
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w500))),
                Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Text('${cours.location} - ${cours.description}', style: TextStyle(fontSize: 14.0))),
                Text(cours.dateForDisplay(),
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[600]))
              ]))
        ]));
  }
}
