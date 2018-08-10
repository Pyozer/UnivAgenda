import 'package:flutter/material.dart';

class LogoApp extends StatelessWidget {

  final image = 'res/images/logo.png';

  final double width;

  const LogoApp({Key key, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(image, width: width);
  }
}
