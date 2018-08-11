import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key key}) : super(key: key);

  Widget _drawerElem(
      BuildContext context, IconData icon, StringKey title, String routeDest) {
    return ListTile(
        leading: Icon(icon),
        title: Text(Translations.of(context).get(title)),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, routeDest);
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
        semanticLabel: Translations.of(context).get(StringKey.DRAWER),
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(Asset.LOGO, width: 65.0),
                  Padding(padding: const EdgeInsets.only(top: 13.0)),
                  Text(Translations.of(context).get(StringKey.APP_NAME),
                      style: const TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.w500))
                ],
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
              )),
          _drawerElem(context, Icons.location_city, StringKey.FINDROOM,
              RouteKey.FINDROOM),
          _drawerElem(
              context, Icons.settings, StringKey.SETTINGS, RouteKey.SETTINGS),
          _drawerElem(
              context, Icons.system_update, StringKey.UPDATE, RouteKey.UPDATE),
          _drawerElem(
              context, Icons.info_outline, StringKey.ABOUT, RouteKey.ABOUT),
          _drawerElem(context, Icons.lightbulb_outline, StringKey.INTRO,
              RouteKey.INTRO),
          _drawerElem(
              context, Icons.exit_to_app, StringKey.LOGOUT, RouteKey.LOGOUT)
        ]));
  }
}
