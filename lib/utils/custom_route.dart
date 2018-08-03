import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {

  CustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute)
      return child;
    return new FadeTransition(opacity: animation, child: child);
  }
}