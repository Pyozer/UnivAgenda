import 'package:flutter/material.dart';
import 'package:myagenda/utils/analytics.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  static const kDurationFade = 150;

  static String lastRoute;
  String routeName;

  CustomRoute({
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool fullscreenDialog: false,
    @required this.routeName,
  })  : assert(builder != null),
        assert(routeName != null),
        super(
            builder: builder,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Duration get transitionDuration =>
      const Duration(milliseconds: kDurationFade);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {

    if (routeName != null && lastRoute != routeName) {
      lastRoute = routeName;
      // Send current screen to analytics
      AnalyticsProvider.of(context)
          .analytics
          .setCurrentScreen(screenName: routeName);
    }

    return (settings.isInitialRoute)
        ? child
        : FadeTransition(opacity: animation, child: child);
  }
}
