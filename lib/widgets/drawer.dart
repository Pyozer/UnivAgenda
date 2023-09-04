import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../keys/string_key.dart';
import '../screens/about/aboutscreen.dart';
import '../screens/help/help.dart';
import '../screens/login/login.dart';
import '../screens/onboarding/onboarding.dart';
import '../screens/settings/settings.dart';
import '../screens/supportme/supportme.dart';
import '../utils/functions.dart';
import '../utils/preferences/settings.provider.dart';
import '../utils/translations.dart';
import 'ui/dialog/dialog_predefined.dart';
import 'ui/logo.dart';

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

    if (logoutConfirm && context.mounted) {
      prefs.disconnectUser();
      navigatorPushReplace(context, const LoginScreen());
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Logo(size: 65.0),
                const Padding(padding: EdgeInsets.only(top: 13.0)),
                Text(
                  i18n.text(StrKey.APP_NAME),
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
          DrawerElement(
            icon: Icons.info_outline,
            title: i18n.text(StrKey.ABOUT),
            routeDest: () => const AboutScreen(),
          ),
          DrawerElement(
            icon: Icons.lightbulb_outline,
            title: i18n.text(StrKey.INTRO),
            routeDest: () => const OnboardingScreen(),
          ),
          DrawerElement(
            icon: Icons.settings_outlined,
            title: i18n.text(StrKey.SETTINGS),
            routeDest: () => const SettingsScreen(),
          ),
          const Divider(),
          DrawerElement(
            icon: Icons.live_help_outlined,
            title: i18n.text(StrKey.HELP_FEEDBACK),
            routeDest: () => const HelpScreen(),
          ),
          DrawerElement(
            icon: Icons.monetization_on_outlined,
            title: i18n.text(StrKey.SUPPORTME),
            routeDest: () => const SupportMeScreen(),
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
