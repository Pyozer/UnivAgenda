import 'package:flutter/material.dart';
import 'package:myagenda/widgets/intro/intromodel.dart';

class IntroScreen extends StatefulWidget {
  final List<PageViewModel> pages;
  final bool skipButton;

  const IntroScreen({Key key, @required this.pages, this.skipButton = false})
      : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final page = widget.pages[currentPage];
    return SafeArea(
      
      color: page.pageColor,
      child: ,
    );
  }
}
