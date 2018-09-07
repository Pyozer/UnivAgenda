import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/screens/about/aboutscreen.dart';
import 'package:myagenda/screens/about/licences/licences.dart';
import 'package:myagenda/screens/findroom/findroom.dart';
import 'package:myagenda/screens/home/home.dart';
import 'package:myagenda/screens/introduction/intro.dart';
import 'package:myagenda/screens/login/login.dart';
import 'package:myagenda/screens/settings/settings.dart';
import 'package:myagenda/screens/splashscreen/splashscreen.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PreferencesProvider(
      prefs: Preferences(),
      child: DynamicTheme(
        defaultTheme: ThemeData(
            fontFamily: 'OpenSans',
            primaryColor: const Color(PrefKey.defaultPrimaryColor),
            accentColor: const Color(PrefKey.defaultAccentColor),
            brightness: getBrightness(PrefKey.defaultDarkTheme)),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "MyAgenda",
            theme: theme,
            localizationsDelegates: [
              const TranslationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [const Locale('en'), const Locale('fr')],
            initialRoute: RouteKey.SPLASHSCREEN,
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case RouteKey.SPLASHSCREEN:
                  return CustomRoute(
                    builder: (_) => SplashScreen(),
                    settings: settings,
                  );
                case RouteKey.HOME:
                  return CustomRoute(
                    builder: (_) => HomeScreen(),
                    settings: settings,
                  );
                case RouteKey.FINDROOM:
                  return CustomRoute(
                    builder: (_) => FindRoomScreen(),
                    settings: settings,
                  );
                case RouteKey.SETTINGS:
                  return CustomRoute(
                    builder: (_) => SettingsScreen(),
                    settings: settings,
                  );
                case RouteKey.UPDATE:
                  return CustomRoute(
                    builder: (_) => AboutScreen(),
                    settings: settings,
                  );
                case RouteKey.ABOUT:
                  return CustomRoute(
                    builder: (_) => AboutScreen(),
                    settings: settings,
                  );
                case RouteKey.LICENCES:
                  return CustomRoute(
                    builder: (_) => LicencesScreen(),
                    settings: settings,
                  );
                case RouteKey.INTRO:
                  return CustomRoute(
                    builder: (_) => IntroductionScreen(),
                    settings: settings,
                  );
                case RouteKey.LOGIN:
                  return CustomRoute(
                    builder: (_) => LoginScreen(),
                    settings: settings,
                  );
              }
              assert(false);
            },
          );
        },
      ),
    );
  }
}
