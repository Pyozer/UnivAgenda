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
          // Add a one-pixel-high divider widget before each row in theListView.
          /*if (index.isOdd)
            return new Divider(
                color: Colors.grey); // notice color is added to style divider
*/
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
    return Card(margin: EdgeInsets.all(8.0),child: ListTile(
      leading: new Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(bottom: 6.0), child: Text("15h30")),
          Text("16h30")
        ],
      ),
      title: Text(title),
      subtitle: Text(description),
    ));


    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Text(description),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
