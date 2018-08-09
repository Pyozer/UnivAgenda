import 'package:flutter/material.dart';
import 'package:myagenda/widgets/intro/intromodel.dart';

class IntroScreen extends StatefulWidget {
  final List<PageViewModel> pages;

  const IntroScreen({Key key, @required this.pages}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
