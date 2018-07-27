import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/screens/home.dart';
import 'package:myagenda/screens/splashscreen.dart';

void main() => runApp(new MaterialApp(
      title: "MyAgenda",
      theme: new ThemeData(primarySwatch: Colors.teal),
      localizationsDelegates: [
        const TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('fr', ''),
      ],
      home: new SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/splashscreen': (BuildContext context) => new SplashScreen(),
        '/home': (BuildContext context) => new HomeScreen(),
      },
    ));
