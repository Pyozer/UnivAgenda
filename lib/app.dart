import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:univagenda/screens/splashscreen/splashscreen.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/preferences/theme.provider.dart';
import 'package:univagenda/utils/theme.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatelessWidget {
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
          final ThemeMode themeMode = prefs.themeMode;

          SystemUiOverlayStyle style = SystemUiOverlayStyle.light;
          if (themeMode == ThemeMode.dark) {
            style = SystemUiOverlayStyle.dark;
          }

          SystemChrome.setSystemUIOverlayStyle(style.copyWith(
            statusBarColor: Colors.transparent,
          ));

          return MaterialApp(
            title: "UnivAgenda",
            themeMode: themeMode,
            theme: generateTheme(
              brightness: Brightness.light,
              primaryColor: prefs.primaryColor,
              accentColor: prefs.accentColor,
            ),
            darkTheme: generateTheme(
              brightness: Brightness.dark,
              primaryColor: prefs.primaryColor,
              accentColor: prefs.accentColor,
            ),
            localizationsDelegates: [
              ...GlobalMaterialLocalizations.delegates,
              SfGlobalLocalizations.delegate
            ],
            supportedLocales: i18n.supportedLocales(),
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
