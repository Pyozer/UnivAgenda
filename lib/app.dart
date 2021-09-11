import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:univagenda/screens/splashscreen/splashscreen.dart';
import 'package:univagenda/utils/functions.dart';
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
          final themePrefs = prefs.theme;
          final theme = ThemeData(
            platform: TargetPlatform.android,
            fontFamily: 'GoogleSans',
            brightness: getBrightness(themePrefs.darkTheme),
            primaryColor: themePrefs.primaryColor,
            accentColor: themePrefs.accentColor,
            toggleableActiveColor: themePrefs.accentColor,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: themePrefs.accentColor,
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
            theme: theme,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: i18n.supportedLocales(),
            home: SplashScreen(),
          );
        },
      ),
    );

    // return PreferencesProvider(
    //   prefs: prefs,
    //   child: Builder(
    //     builder: (context) {
    //       final themePrefs = PreferencesProvider.of(context).theme;
    //       final theme = ThemeData(
    //         platform: TargetPlatform.android,
    //         fontFamily: 'GoogleSans',
    //         brightness: getBrightness(themePrefs.darkTheme),
    //         primaryColor: themePrefs.primaryColor,
    //         accentColor: themePrefs.accentColor,
    //         toggleableActiveColor: themePrefs.accentColor,
    //         textSelectionTheme: TextSelectionThemeData(
    //           cursorColor: themePrefs.accentColor,
    //         ),
    //       );

    //       SystemUiOverlayStyle style = theme.brightness == Brightness.dark
    //           ? SystemUiOverlayStyle.light
    //           : SystemUiOverlayStyle.dark;

    //       SystemChrome.setSystemUIOverlayStyle(style.copyWith(
    //         statusBarColor: Colors.transparent,
    //       ));

    //       return MaterialApp(
    //         title: "UnivAgenda",
    //         theme: theme,
    //         localizationsDelegates: [
    //           GlobalMaterialLocalizations.delegate,
    //           GlobalWidgetsLocalizations.delegate,
    //         ],
    //         supportedLocales: i18n.supportedLocales(),
    //         initialRoute: RouteKey.SPLASHSCREEN,
    //         onGenerateRoute: (RouteSettings settings) {
    //           if (routes.containsKey(settings.name))
    //             return CustomRoute(
    //               builder: (_) => routes[settings.name]!,
    //               settings: settings,
    //             );
    //           assert(false);
    //           return null;
    //         },
    //       );
    //     },
    //   ),
    // );
  }
}
