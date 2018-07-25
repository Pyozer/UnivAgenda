import 'package:flutter/material.dart';
import 'package:myagenda/screens/home.dart';
import 'package:myagenda/screens/splashscreen.dart';

const String appTitle = "MyAgenda";

void main() => runApp(new MaterialApp(
      title: appTitle,
      theme: new ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: new SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/splashscreen': (BuildContext context) => new SplashScreen(),
        '/home': (BuildContext context) => new HomeScreen(title: appTitle),
      },
    ));
