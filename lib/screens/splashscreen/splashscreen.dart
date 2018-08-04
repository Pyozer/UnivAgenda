import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/widgets/logo_app.dart';

class SplashScreen extends StatelessWidget {

  startTime(BuildContext context) async {
    var _duration = Duration(seconds: 3);
    return Timer(_duration, () => Navigator.of(context).pushReplacementNamed('/'));
  }

  @override
  Widget build(BuildContext context) {
    startTime(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LogoApp(),
            const Padding(padding: EdgeInsets.only(top: 100.0)),
            const CircularProgressIndicator(
              strokeWidth: 5.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red)
            )
          ]
        )
      )
    );
  }
}