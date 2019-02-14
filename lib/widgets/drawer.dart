import 'package:flutter/material.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/course/course_list_header.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/logo.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key key}) : super(key: key);

  void _onDisconnectPressed(BuildContext context) async {
    final prefs = PreferencesProvider.of(context);

    bool logoutConfirm = await DialogPredefined.showTextDialog(
        context,
        translations.text(StrKey.LOGOUT),
        translations.text(StrKey.LOGOUT_CONFIRM),
        translations.text(StrKey.YES),
        translations.text(StrKey.NO),
        true);

    if (logoutConfirm) {
      prefs.disconnectUser();
      Navigator.of(context).pushReplacementNamed(RouteKey.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = PreferencesProvider.of(context);

    return Drawer(
      semanticLabel: translations.text(StrKey.DRAWER),
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
                  translations.text(StrKey.APP_NAME),
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
                      ? const Color(0xFF484848)
                      : const Color(0xFFF3F3F3),
                )
              : const SizedBox.shrink(),
          DrawerElement(
            icon: OMIcons.search,
            title: translations.text(StrKey.FINDSCHEDULES),
            routeDest: RouteKey.FINDSCHEDULES,
            enabled: prefs.urlIcs == null,
          ),
          DrawerElement(
            icon: OMIcons.info,
            title: translations.text(StrKey.ABOUT),
            routeDest: RouteKey.ABOUT,
          ),
          DrawerElement(
            icon: Icons.lightbulb_outline,
            title: translations.text(StrKey.INTRO),
            routeDest: RouteKey.INTRO,
          ),
          const Divider(),
          DrawerElement(
            icon: OMIcons.settings,
            title: translations.text(StrKey.SETTINGS),
            routeDest: RouteKey.SETTINGS,
          ),
          DrawerElement(
            icon: OMIcons.liveHelp,
            title: translations.text(StrKey.HELP_FEEDBACK),
            routeDest: RouteKey.HELP,
          ),
          DrawerElement(
            icon: OMIcons.monetizationOn,
            title: translations.text(StrKey.SUPPORTME),
            routeDest: RouteKey.SUPPORTME,
          ),
          const Divider(),
          DrawerElement(
            icon: OMIcons.exitToApp,
            title: translations.text(StrKey.LOGOUT),
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
