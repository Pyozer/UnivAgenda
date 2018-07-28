import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myagenda/screens/about/aboutscreen.dart';
import 'package:myagenda/screens/introduction/intro.dart';
import 'package:myagenda/screens/settings/settings.dart';
import 'package:myagenda/screens/home/home.dart';
import 'package:myagenda/screens/settings/settings_display.dart';
import 'package:myagenda/screens/settings/settings_general.dart';
import 'package:myagenda/screens/splashscreen/splashscreen.dart';
import 'package:myagenda/translate/translations.dart';

final routes = {
  '/splashscreen': SplashScreen(),
  '/': HomeScreen(),
  '/findroom': AboutScreen(),
  '/settings': SettingsScreen(),
  '/settings/general': SettingsGeneralScreen(),
  '/settings/display': SettingsDisplayScreen(),
  '/update': AboutScreen(),
  '/about': AboutScreen(),
  '/intro': IntroductionScreen(),
  '/logout': AboutScreen()
};

class MyCustomRoute<T> extends MaterialPageRoute<T> {

  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 125);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute)
      return child;
    return new FadeTransition(opacity: animation, child: child);
  }
}

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


