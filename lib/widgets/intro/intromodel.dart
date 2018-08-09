import 'package:flutter/material.dart';

class PageViewModel {
  /// Background page color
  ///
  /// @Default `Colors.white`
  final Color pageColor;

  /// color for background of progress bubbles
  ///
  /// @Default `Colors.blue`
  final Color bubbleBackgroundColor;

  /// Title of page
  ///
  /// @Default style `color: Colors.black , fontSize: 32.0, fontWeight: FontWeight.w600`
  final Text title;

  /// Text of page (description)
  ///
  /// @Default style `color: Colors.grey , fontSize: 22.0`
  final Text body;

  /// TextStyle for title
  final TextStyle titleTextStyle;

  /// TextStyle for title
  final TextStyle bodyTextStyle;

  /// Image Widget
  final Image mainImage;

  PageViewModel({this.pageColor = Colors.white,
    this.bubbleBackgroundColor = Colors.blue,
    @required this.title,
    @required this.body,
    @required this.mainImage,
    this.titleTextStyle = const TextStyle(
        color: Colors.black, fontSize: 32.0, fontWeight: FontWeight.w600),
    this.bodyTextStyle = const TextStyle(color: const Color(0xFF555555), fontSize: 22.0)});

}
