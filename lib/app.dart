import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

import 'screens/splashscreen/splashscreen.dart';
import 'utils/preferences/settings.provider.dart';
import 'utils/preferences/theme.provider.dart';
import 'utils/theme.dart';
import 'utils/translations.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(
          value: SettingsProvider.instance,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(
          value: ThemeProvider.instance,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, prefs, _) {
          final lightTheme = generateTheme(
            brightness: Brightness.light,
            primaryColor: prefs.primaryColor,
            accentColor: prefs.accentColor,
          );

          final darkTheme = generateTheme(
            brightness: Brightness.dark,
            primaryColor: prefs.primaryColor,
            accentColor: prefs.accentColor,
          );

          final platformBrightness = MediaQuery.of(context).platformBrightness;
          final themeMode = prefs.themeMode;

          bool isDark = false;
          if (themeMode == ThemeMode.dark) {
            isDark = true;
          } else if (themeMode == ThemeMode.system &&
              platformBrightness == Brightness.dark) {
            isDark = true;
          }

          SystemUiOverlayStyle baseStyle =
              isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: baseStyle.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: isDark
                  ? darkTheme.colorScheme.surface
                  : lightTheme.colorScheme.surface,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
            child: MaterialApp(
              title: 'UnivAgenda',
              themeMode: themeMode,
              theme: lightTheme,
              darkTheme: darkTheme,
              localizationsDelegates: const [
                ...GlobalMaterialLocalizations.delegates,
                SfGlobalLocalizations.delegate
              ],
              supportedLocales: i18n.supportedLocales(),
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
