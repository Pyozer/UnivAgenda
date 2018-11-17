import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/widgets/course/course_list_header.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key key}) : super(key: key);

  void _onDisconnectPressed(BuildContext context) async {
    final prefs = PreferencesProvider.of(context);

    bool logoutConfirm = await DialogPredefined.showTextDialog(
      context,
      FlutterI18n.translate(context, StrKey.LOGOUT),
      FlutterI18n.translate(context, StrKey.LOGOUT_CONFIRM),
      FlutterI18n.translate(context, StrKey.YES),
      FlutterI18n.translate(context, StrKey.NO),
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
    final prefs = PreferencesProvider.of(context);

    return Drawer(
      semanticLabel: FlutterI18n.translate(context, StrKey.DRAWER),
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
                  FlutterI18n.translate(context, StrKey.APP_NAME),
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
            title: FlutterI18n.translate(context, StrKey.FINDSCHEDULES),
            routeDest: RouteKey.FINDSCHEDULES,
            enabled: prefs.urlIcs == null,
          ),
          DrawerElement(
            icon: OMIcons.info,
            title: FlutterI18n.translate(context, StrKey.ABOUT),
            routeDest: RouteKey.ABOUT,
          ),
          DrawerElement(
            icon: Icons.lightbulb_outline,
            title: FlutterI18n.translate(context, StrKey.INTRO),
            routeDest: RouteKey.INTRO,
          ),
          const Divider(),
          DrawerElement(
            icon: OMIcons.settings,
            title: FlutterI18n.translate(context, StrKey.SETTINGS),
            routeDest: RouteKey.SETTINGS,
          ),
          DrawerElement(
            icon: OMIcons.liveHelp,
            title: FlutterI18n.translate(context, StrKey.HELP_FEEDBACK),
            routeDest: RouteKey.HELP,
          ),
          DrawerElement(
            icon: OMIcons.monetizationOn,
            title: FlutterI18n.translate(context, StrKey.SUPPORTME),
            routeDest: RouteKey.SUPPORTME,
          ),
          const Divider(),
          DrawerElement(
            icon: OMIcons.exitToApp,
            title: FlutterI18n.translate(context, StrKey.LOGOUT),
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
