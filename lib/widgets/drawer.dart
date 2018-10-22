import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course/course_list_header.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key key}) : super(key: key);

  void _onDisconnectPressed(BuildContext context) async {
    final translations = Translations.of(context);
    final prefs = PreferencesProvider.of(context);

    bool logoutConfirm = await DialogPredefined.showTextDialog(
      context,
      translations.get(StringKey.LOGOUT),
      translations.get(StringKey.LOGOUT_CONFIRM),
      translations.get(StringKey.YES),
      translations.get(StringKey.NO),
      true,
      TextAlign.left,
    );

    if (logoutConfirm) {
      prefs.disconnectUser();
      Navigator.of(context).pushReplacementNamed(RouteKey.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    final prefs = PreferencesProvider.of(context);

    return Drawer(
      semanticLabel: translations.get(StringKey.DRAWER),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(16.0),
            margin: EdgeInsets.zero,
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
          prefs.urlIcs == null
              ? CourseListHeader(
                  "${prefs.groupKeys[1]} - ${prefs.groupKeys.last}",
                  bgColor: prefs.theme.darkTheme
                      ? const Color(0x21FFFFFF)
                      : const Color(0x18000000),
                )
              : const SizedBox.shrink(),
          DrawerElement(
            icon: OMIcons.search,
            title: translations.get(StringKey.FINDSCHEDULES),
            routeDest: RouteKey.FINDSCHEDULES,
            enabled: prefs.urlIcs == null,
          ),
          DrawerElement(
            icon: OMIcons.info,
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
            icon: OMIcons.settings,
            title: translations.get(StringKey.SETTINGS),
            routeDest: RouteKey.SETTINGS,
          ),
          DrawerElement(
            icon: OMIcons.liveHelp,
            title: translations.get(StringKey.HELP_FEEDBACK),
            routeDest: RouteKey.HELP,
          ),
          DrawerElement(
            icon: OMIcons.monetizationOn,
            title: translations.get(StringKey.SUPPORTME),
            routeDest: RouteKey.SUPPORTME,
          ),
          const Divider(),
          DrawerElement(
            icon: OMIcons.exitToApp,
            title: translations.get(StringKey.LOGOUT),
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
