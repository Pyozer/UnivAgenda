import 'package:flutter/material.dart';
import 'package:myagenda/widgets/CoursList.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Widget _buildDrawer() {
    return new Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(
          child: Text('Drawer Header'),
          decoration: BoxDecoration(color: Colors.blue)),
      ListTile(
          title: Text('Item 1'),
          onTap: () {
            Navigator.pop(context);
          }),
      ListTile(
          title: Text('Item 2'),
          onTap: () {
            Navigator.pop(context);
          })
    ]));
  }

  Widget _buildFab() {
    return new FloatingActionButton(
        onPressed: () {
          print('salut');
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text(widget.title)),
        drawer: _buildDrawer(),
        body: new CoursList(),
        floatingActionButton: _buildFab());
  }
}
