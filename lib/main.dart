import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myagenda/customroute.dart';
import 'package:myagenda/screens/aboutscreen.dart';
import 'package:myagenda/screens/intro.dart';
import 'package:myagenda/screens/settings.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/screens/home.dart';
import 'package:myagenda/screens/splashscreen.dart';

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

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "MyAgenda",
    theme: ThemeData(primarySwatch: Colors.red),
    localizationsDelegates: [
      const TranslationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('en', ''),
      const Locale('fr', ''),
    ],
    initialRoute: '/splashscreen',
    onGenerateRoute: (RouteSettings settings) {
      if (routes.containsKey(settings.name))
        return new MyCustomRoute(
            builder: (_) => routes[settings.name], settings: settings);
      assert(false);
    }));
