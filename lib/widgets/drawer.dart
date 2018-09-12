import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:url_launcher/url_launcher.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return Drawer(
      semanticLabel: translations.get(StringKey.DRAWER),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
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
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          DrawerElement(
            icon: Icons.location_city,
            title: translations.get(StringKey.FINDROOM),
            routeDest: RouteKey.FINDROOM,
          ),
          DrawerElement(
            icon: Icons.info_outline,
            title: translations.get(StringKey.ABOUT),
            routeDest: RouteKey.ABOUT,
          ),
          DrawerElement(
            icon: Icons.lightbulb_outline,
            title: translations.get(StringKey.INTRO),
            routeDest: RouteKey.INTRO,
          ),
          const Divider(),
          DrawerElement(
            icon: Icons.settings,
            title: translations.get(StringKey.SETTINGS),
            routeDest: RouteKey.SETTINGS,
          ),
          DrawerElement(
            icon: Icons.help,
            title: translations.get(StringKey.HELP_FEEDBACK),
            routeDest: RouteKey.HELP,
          ),
          const Divider(),
          DrawerElement(
            icon: Icons.exit_to_app,
            title: translations.get(StringKey.LOGOUT),
            routeDest: RouteKey.LOGIN,
            onTap: () {
              PreferencesProvider.of(context).setUserLogged(false, false);
              Navigator.of(context).pushReplacementNamed(RouteKey.LOGIN);
            },
          )
        ],
      ),
    );
  }
}

class DrawerElement extends StatelessWidget {
  final IconData icon;
  final String title;
  final String routeDest;
  final Function onTap;
  final bool enabled;

  const DrawerElement(
      {Key key,
      @required this.icon,
      @required this.title,
      this.routeDest,
      this.onTap,
      this.enabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (onTap != null)
          onTap();
        else if (routeDest != null)
          Navigator.of(context).popAndPushNamed(routeDest);
      },
      enabled: enabled,
    );
  }
}
