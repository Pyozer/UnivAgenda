import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:univagenda/screens/splashscreen/splashscreen.dart';
import 'package:univagenda/utils/preferences.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PrefsProvider>.value(
          value: PrefsProvider.instance,
        ),
      ],
      child: Consumer<PrefsProvider>(
        builder: (context, prefs, _) {
          final theme = ThemeData(
            platform: TargetPlatform.android,
            fontFamily: 'GoogleSans',
            brightness: prefs.theme.brightness,
            primaryColor: prefs.theme.primaryColor,
            toggleableActiveColor: prefs.theme.accentColor,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: prefs.theme.accentColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                  prefs.theme.darkTheme ? Colors.white : Colors.black,
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
                primary: prefs.theme.primaryColor,
                secondary: prefs.theme.accentColor,
                onSecondary: Colors.white,
              ),
            ),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: i18n.supportedLocales(),
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
