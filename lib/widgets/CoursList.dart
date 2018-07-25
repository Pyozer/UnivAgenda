import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:myagenda/models/Cours.dart';
import 'package:myagenda/utils/ical.dart';

class CoursList extends StatefulWidget {
  final int resId;

  CoursList({Key key, this.resId}) : super(key: key);

  @override
  State<CoursList> createState() => new CoursListState();
}

class CoursListState extends State<CoursList> {
  List<Cours> _cours = [];

  Future<String> _fetchData() async {
    final response = await http.get('https://pastebin.com/raw/Mnjd86L1');

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load ical');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData().then((response) {
      List<Cours> cours = [];
      Ical.parseToIcal(response).forEach((icalModel) {
        cours.add(Cours.fromIcalModel(icalModel));
      });

      setState(() {
        _cours = cours;
      });
    });
  }

  Widget _buildRow(int index) {
    var dateStart = _cours[index].dateStart;
    var dateEnd = _cours[index].dateEnd;

    return new CoursRow(
        title: _cours[index].title,
        description: _cours[index].description,
        date: dateStart.toString() +
            " " +
            dateEnd.hour.toString() +
            "h" +
            dateEnd.minute.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return _buildRow(index);
        },
        itemCount: _cours.length);
  }
}

class CoursRow extends StatelessWidget {
  final String title;
  final String description;
  final String date;

  const CoursRow({Key key, this.title, this.description, this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            new Text(description),
            new Text(date)
          ],
        ));
  }
}
