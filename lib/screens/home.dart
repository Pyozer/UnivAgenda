import 'package:flutter/material.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/widgets/CoursList.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Widget _drawerElem(IconData icon, Translate title, Function onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(Translations.of(context).text(title)),
      onTap: onTap
    );
  }

  Widget _buildDrawer() {
    final translations = Translations.of(context);
    return new Drawer(
        semanticLabel: translations.text(Translate.DRAWER),
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      children: [
                        Image.asset('images/logo.png', width: 65.0),
                        Padding(padding: const EdgeInsets.only(top: 13.0)),
                        Text(
                            translations.text(Translate.APP_NAME),
                            style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w500
                            )
                        )
                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                  )
              ),
              _drawerElem(Icons.location_city, Translate.FINDROOM, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/findroom');
              }),
              _drawerElem(Icons.settings, Translate.SETTINGS, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              }),
              _drawerElem(Icons.system_update, Translate.UPDATE, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/update');
              }),
              _drawerElem(Icons.info_outline, Translate.ABOUT, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              }),
              _drawerElem(Icons.lightbulb_outline, Translate.INTRO, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/intro');
              }),
              _drawerElem(Icons.exit_to_app, Translate.LOGOUT, () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/logout');
              })
            ]
        )
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {},
      tooltip: 'Increment',
      child: Icon(Icons.add)
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text(Translations.of(context).text(Translate.APP_NAME))
        ),
        drawer: _buildDrawer(),
        body: new CoursList(),
        floatingActionButton: _buildFab()
    );
  }
}