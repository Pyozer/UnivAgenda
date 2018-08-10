import 'package:flutter/material.dart';

class PageViewModel {
  /// Background page color
  ///
  /// @Default `Colors.white`
  final Color pageColor;

  /// Progress indicator color
  ///
  /// @Default `Colors.blue`
  final Color progressColor;

  /// Button next (or done) color
  ///
  /// @Default `Colors.blue`
  final Color buttonColor;

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

  /// Image of page
  final Image image;

  PageViewModel(
      {this.pageColor = Colors.white,
      this.progressColor = Colors.blue,
      this.buttonColor = Colors.blue,
      @required this.title,
      @required this.body,
      @required this.image,
      this.titleTextStyle = const TextStyle(
          color: Colors.black, fontSize: 32.0, fontWeight: FontWeight.w600),
      this.bodyTextStyle =
          const TextStyle(color: const Color(0xFF555555), fontSize: 22.0)});
}
