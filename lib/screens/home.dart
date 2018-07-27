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
    return new Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                      child: Column(
                        children: <Widget>[
                          Image.asset('images/logo.png', width: 65.0),
                          Padding(
                              padding: EdgeInsets.only(top: 13.0),
                              child: Text(
                                  Translations.of(context).text(Translate.APP_NAME),
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w500
                                  )
                              )
                          )
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                      )
                  )
              ),
              _drawerElem(Icons.location_city, Translate.DRAWER_FINDROOM, () {
                Navigator.pop(context);
                // TODO: Afficher FindRoomScreen
              }),
              _drawerElem(Icons.settings, Translate.DRAWER_SETTINGS, () {
                Navigator.pop(context);
                // TODO: Afficher SettingsScreen
              }),
              _drawerElem(Icons.system_update, Translate.DRAWER_UPDATE, () {
                Navigator.pop(context);
                // TODO: Afficher UpdateScreen
              }),
              _drawerElem(Icons.info_outline, Translate.DRAWER_ABOUT, () {
                Navigator.pop(context);
                // TODO: Afficher AboutScreen
              }),
              _drawerElem(Icons.lightbulb_outline, Translate.DRAWER_INTRO, () {
                Navigator.pop(context);
                // TODO: Afficher IntroScreen
              }),
              _drawerElem(Icons.exit_to_app, Translate.DRAWER_LOGOUT, () {
                Navigator.pop(context);
                // TODO: Afficher LogoutScreen
              }),
            ]
        )
    );
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
        appBar: new AppBar(
            title: new Text(Translations.of(context).text(Translate.APP_NAME))),
        drawer: _buildDrawer(),
        body: new CoursList(),
        floatingActionButton: _buildFab());
  }
}
