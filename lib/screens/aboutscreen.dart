import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myagenda/translate/translations.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => new _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translations.of(context);

    return Scaffold(
        appBar: AppBar(
            title: Text(translate.text(Translate.ABOUT))
        ),
        body: Container(
          child: Center(
            child: Text(translate.text(Translate.ABOUT)),
          )
        )
    );
  }
}
