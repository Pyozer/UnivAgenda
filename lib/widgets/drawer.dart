import 'package:flutter/material.dart';

import '../keys/string_key.dart';
import '../screens/about/aboutscreen.dart';
import '../screens/help/help.dart';
import '../screens/onboarding/onboarding.dart';
import '../screens/settings/settings.dart';
import '../screens/supportme/supportme.dart';
import '../utils/functions.dart';
import '../utils/translations.dart';
import 'ui/logo.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  void _closeDrawerAndPush(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    navigatorPush(context, screen);
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
            onTap: () => _closeDrawerAndPush(context, const AboutScreen()),
          ),
          DrawerElement(
            icon: Icons.lightbulb_outline,
            title: i18n.text(StrKey.INTRO),
            onTap: () => _closeDrawerAndPush(
              context,
              const OnboardingScreen(shouldPopOnDone: true),
            ),
          ),
          DrawerElement(
            icon: Icons.settings_outlined,
            title: i18n.text(StrKey.SETTINGS),
            onTap: () => _closeDrawerAndPush(context, const SettingsScreen()),
          ),
          const Divider(),
          DrawerElement(
            icon: Icons.live_help_outlined,
            title: i18n.text(StrKey.HELP_FEEDBACK),
            onTap: () => _closeDrawerAndPush(context, const HelpScreen()),
          ),
          DrawerElement(
            icon: Icons.monetization_on_outlined,
            title: i18n.text(StrKey.SUPPORTME),
            onTap: () => _closeDrawerAndPush(context, const SupportMeScreen()),
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
  final GestureTapCallback? onTap;
  final bool enabled;

  const DrawerElement({
    Key? key,
    required this.icon,
    required this.title,
    this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      enabled: enabled,
    );
  }
}
