import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  static const kDurationFade = 150;

  CustomRoute(
      {WidgetBuilder builder,
      RouteSettings settings,
      bool fullscreenDialog: false})
      : super(
            builder: builder,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Duration get transitionDuration =>
      const Duration(milliseconds: kDurationFade);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return (settings.isInitialRoute)
        ? child
        : FadeTransition(opacity: animation, child: child);
  }
}
