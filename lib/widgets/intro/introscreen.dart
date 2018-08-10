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
      child: Container(
        color: page.pageColor,
        child: Column(
          children: <Widget>[
            new Expanded(
              child: new Container(
                decoration: const BoxDecoration(color: Colors.red),
              ),
              flex: 3,
            ),
            new Expanded(
              child: new Container(
                decoration: const BoxDecoration(color: Colors.green),
              ),
              flex: 2,
            ),
            new Expanded(
              child: new Container(
                decoration: const BoxDecoration(color: Colors.blue),
              ),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}
