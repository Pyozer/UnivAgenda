import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:url_launcher/url_launcher.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key key}) : super(key: key);

  Widget _drawerElem(
      BuildContext context, IconData icon, StringKey title, String routeDest,
      {bool enabled = true, Function onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(Translations.of(context).get(title)),
      onTap: () {
        if (onTap != null)
          onTap();
        else
          Navigator.of(context).popAndPushNamed(routeDest);
      },
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return Drawer(
        semanticLabel: translations.get(StringKey.DRAWER),
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Hero(
                  tag: Asset.LOGO,
                  child: Image.asset(Asset.LOGO, width: 65.0),
                ),
                const Padding(padding: const EdgeInsets.only(top: 13.0)),
                Text(
                  translations.get(StringKey.APP_NAME),
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.w500),
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          _drawerElem(
            context,
            Icons.location_city,
            StringKey.FINDROOM,
            RouteKey.FINDROOM,
          ),
          _drawerElem(
            context,
            Icons.info_outline,
            StringKey.ABOUT,
            RouteKey.ABOUT,
          ),
          _drawerElem(
            context,
            Icons.lightbulb_outline,
            StringKey.INTRO,
            RouteKey.INTRO,
          ),
          Divider(),
          _drawerElem(
            context,
            Icons.settings,
            StringKey.SETTINGS,
            RouteKey.SETTINGS,
          ),
          _drawerElem(
            context,
            Icons.system_update,
            StringKey.UPDATE,
            RouteKey.UPDATE,
            enabled: false,
          ),
          _drawerElem(
            context,
            Icons.feedback,
            StringKey.FEEDBACK,
            null,
            onTap: () async {
              var url =
                  'mailto:jeancharles.msse@gmail.com?subject=Feedback MyAgenda';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                Navigator.of(context).pop();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      translations.get(StringKey.NO_EMAIL_APP),
                    ),
                  ),
                );
              }
            },
          ),
          Divider(),
          _drawerElem(
            context,
            Icons.exit_to_app,
            StringKey.LOGOUT,
            RouteKey.LOGIN,
            onTap: () {
              PreferencesProvider.of(context).userLogged = false;
              Navigator.of(context).pushReplacementNamed(RouteKey.LOGIN);
            },
          )
        ]));
  }
}
