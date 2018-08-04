import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myagenda/screens/about/aboutscreen.dart';
import 'package:myagenda/screens/home/home.dart';
import 'package:myagenda/screens/introduction/intro.dart';
import 'package:myagenda/screens/settings/settings.dart';
import 'package:myagenda/screens/splashscreen/splashscreen.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/custom_route.dart';

final routes = {
  '/splashscreen': SplashScreen(),
  '/': HomeScreen(),
  '/findroom': AboutScreen(),
  '/settings': SettingsScreen(),
  '/update': AboutScreen(),
  '/about': AboutScreen(),
  '/intro': IntroductionScreen(),
  '/logout': AboutScreen()
};

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultTheme: ThemeData(
            accentColor: Colors.red,
            primaryColor: Colors.red,
            brightness: Brightness.light),
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
              supportedLocales: [
                const Locale('en'),
                const Locale('fr'),
              ],
              initialRoute: '/splashscreen',
              onGenerateRoute: (RouteSettings settings) {
                if (routes.containsKey(settings.name))
                  return CustomRoute(
                      builder: (_) => routes[settings.name],
                      settings: settings);
                assert(false);
              });
        });
  }
}