import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:univagenda/screens/splashscreen/splashscreen.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/preferences/theme.provider.dart';
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
          final theme = ThemeData(
            platform: TargetPlatform.android,
            fontFamily: 'GoogleSans',
            brightness: prefs.brightness,
            primaryColor: prefs.primaryColor,
            toggleableActiveColor: prefs.accentColor,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: prefs.accentColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                  prefs.darkTheme ? Colors.white : Colors.black,
                ),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          );

          SystemUiOverlayStyle style = theme.brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark;

          SystemChrome.setSystemUIOverlayStyle(style.copyWith(
            statusBarColor: Colors.transparent,
          ));

          return MaterialApp(
            title: "UnivAgenda",
            theme: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: prefs.primaryColor,
                secondary: prefs.accentColor,
                onSecondary: Colors.white,
              ),
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
