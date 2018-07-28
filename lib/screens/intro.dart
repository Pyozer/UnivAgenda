import 'package:flutter/material.dart';
import 'package:myagenda/translate/translations.dart';

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => new _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
          child: Text(Translations.of(context).text(Translate.INTRO))),
    );
  }
}
