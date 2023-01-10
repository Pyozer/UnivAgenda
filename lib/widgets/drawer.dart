import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/screens/about/aboutscreen.dart';
import 'package:univagenda/screens/help/help.dart';
import 'package:univagenda/screens/login/login.dart';
import 'package:univagenda/screens/onboarding/onboarding.dart';
import 'package:univagenda/screens/settings/settings.dart';
import 'package:univagenda/screens/supportme/supportme.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:univagenda/widgets/ui/logo.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  void _onDisconnectPressed(BuildContext context) async {
    final prefs = context.read<SettingsProvider>();

    bool logoutConfirm = await DialogPredefined.showTextDialog(
        context,
        i18n.text(StrKey.LOGOUT),
        i18n.text(StrKey.LOGOUT_CONFIRM),
        i18n.text(StrKey.YES),
        i18n.text(StrKey.NO),
        true);

    if (logoutConfirm) {
      prefs.disconnectUser();
      navigatorPushReplace(context, LoginScreen());
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
            icon: Icons.info_outline,
            title: i18n.text(StrKey.ABOUT),
            routeDest: () => AboutScreen(),
          ),
          DrawerElement(
            icon: Icons.lightbulb_outline,
            title: i18n.text(StrKey.INTRO),
            routeDest: () => OnboardingScreen(),
          ),
          const Divider(),
          DrawerElement(
            icon: Icons.settings_outlined,
            title: i18n.text(StrKey.SETTINGS),
            routeDest: () => SettingsScreen(),
          ),
          DrawerElement(
            icon: Icons.live_help_outlined,
            title: i18n.text(StrKey.HELP_FEEDBACK),
            routeDest: () => HelpScreen(),
          ),
          DrawerElement(
            icon: Icons.monetization_on_outlined,
            title: i18n.text(StrKey.SUPPORTME),
            routeDest: () => SupportMeScreen(),
          ),
          const Divider(),
          DrawerElement(
            icon: Icons.exit_to_app_outlined,
            title: i18n.text(StrKey.LOGOUT),
            onTap: () => _onDisconnectPressed(context),
          ),
        ],
      ),
    );
  }
}

typedef WidgetCallback = Widget Function();

class DrawerElement extends StatelessWidget {
  final IconData icon;
  final String title;
  final WidgetCallback? routeDest;
  final Function? onTap;
  final bool enabled;

  const DrawerElement({
    Key? key,
    required this.icon,
    required this.title,
    this.routeDest,
    this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (routeDest != null) {
          navigatorPopAndPush(context, routeDest!());
        }
      },
      enabled: enabled,
    );
  }
}
