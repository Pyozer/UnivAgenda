import 'package:flutter/material.dart';
import 'package:univagenda/keys/route_key.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/utils/preferences.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:univagenda/widgets/ui/logo.dart';
import 'package:outline_material_icons_tv/outline_material_icons.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  void _onDisconnectPressed(BuildContext context) async {
    final prefs = PreferencesProvider.of(context);

    bool logoutConfirm = await DialogPredefined.showTextDialog(
        context,
        i18n.text(StrKey.LOGOUT),
        i18n.text(StrKey.LOGOUT_CONFIRM),
        i18n.text(StrKey.YES),
        i18n.text(StrKey.NO),
        true);

    if (logoutConfirm) {
      prefs.disconnectUser();
      Navigator.of(context).pushReplacementNamed(RouteKey.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      semanticLabel: i18n.text(StrKey.DRAWER),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(16.0),
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                Logo(size: 65.0),
                const Padding(padding: const EdgeInsets.only(top: 13.0)),
                Text(
                  i18n.text(StrKey.APP_NAME),
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
            icon: OMIcons.info,
            title: i18n.text(StrKey.ABOUT),
            routeDest: RouteKey.ABOUT,
          ),
          DrawerElement(
            icon: Icons.lightbulb_outline,
            title: i18n.text(StrKey.INTRO),
            routeDest: RouteKey.INTRO,
          ),
          const Divider(),
          DrawerElement(
            icon: OMIcons.settings,
            title: i18n.text(StrKey.SETTINGS),
            routeDest: RouteKey.SETTINGS,
          ),
          DrawerElement(
            icon: OMIcons.liveHelp,
            title: i18n.text(StrKey.HELP_FEEDBACK),
            routeDest: RouteKey.HELP,
          ),
          DrawerElement(
            icon: OMIcons.monetizationOn,
            title: i18n.text(StrKey.SUPPORTME),
            routeDest: RouteKey.SUPPORTME,
          ),
          const Divider(),
          DrawerElement(
            icon: OMIcons.exitToApp,
            title: i18n.text(StrKey.LOGOUT),
            routeDest: RouteKey.LOGIN,
            onTap: () => _onDisconnectPressed(context),
          ),
        ],
      ),
    );
  }
}

class DrawerElement extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? routeDest;
  final Function? onTap;
  final bool enabled;

  const DrawerElement(
      {Key? key,
      required this.icon,
      required this.title,
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
        if (onTap != null) {
          onTap!();
        } else if (routeDest != null) {
          Navigator.of(context).popAndPushNamed(routeDest!);
        }
      },
      enabled: enabled,
    );
  }
}
