import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/screens/about/aboutscreen.dart';
import 'package:myagenda/screens/about/licences/licences.dart';
import 'package:myagenda/screens/find_schedules/find_schedules.dart';
import 'package:myagenda/screens/help/help.dart';
import 'package:myagenda/screens/home/home.dart';
import 'package:myagenda/screens/introduction/intro.dart';
import 'package:myagenda/screens/login/login.dart';
import 'package:myagenda/screens/settings/settings.dart';
import 'package:myagenda/screens/splashscreen/splashscreen.dart';
import 'package:myagenda/screens/supportme/supportme.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/dynamic_theme.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';

final routes = {
  RouteKey.SPLASHSCREEN: SplashScreen(),
  RouteKey.HOME: HomeScreen(),
  RouteKey.FINDSCHEDULES: FindSchedulesScreen(),
  RouteKey.SETTINGS: SettingsScreen(),
  RouteKey.HELP: HelpScreen(),
  RouteKey.ABOUT: AboutScreen(),
  RouteKey.LICENCES: LicencesScreen(),
  RouteKey.INTRO: IntroductionScreen(),
  RouteKey.LOGIN: LoginScreen(),
  RouteKey.SUPPORTME: SupportMeScreen(),
};

class App extends StatelessWidget {
  static var analytics = FirebaseAnalytics();
  static var observer = FirebaseAnalyticsObserver(analytics: analytics);

  Locale _resolveFallback(Locale locale, Iterable<Locale> supportedLocales) {
    if (locale == null) return supportedLocales.first;
    
    return supportedLocales.firstWhere(
      (supported) =>
          supported.languageCode == locale.languageCode ||
          supported.countryCode == locale.countryCode,
      orElse: () => supportedLocales.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return AnalyticsProvider(
      analytics,
      observer,
      child: PreferencesProvider(
        child: Builder(
          builder: (context) {
            final themePrefs = PreferencesProvider.of(context).theme;

            final theme = ThemeData(
              fontFamily: 'GoogleSans',
              brightness: getBrightness(themePrefs.darkTheme),
              primaryColor: Color(themePrefs.primaryColor),
              accentColor: Color(themePrefs.accentColor),
            );

            return DynamicTheme(
              theme: theme,
              themedWidgetBuilder: (context, theme) {
                SystemUiOverlayStyle style = theme.brightness == Brightness.dark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark;

                SystemChrome.setSystemUIOverlayStyle(style.copyWith(
                  statusBarColor: Colors.transparent,
                ));

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: "MyAgenda",
                  theme: theme,
                  localizationsDelegates: [
                    FlutterI18nDelegate(false, 'en', 'res/locales'),
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('fr'), Locale('en')],
                  localeResolutionCallback: _resolveFallback,
                  navigatorObservers: [observer],
                  initialRoute: RouteKey.SPLASHSCREEN,
                  onGenerateRoute: (RouteSettings settings) {
                    if (routes.containsKey(settings.name))
                      return CustomRoute(
                        builder: (_) => routes[settings.name],
                        settings: settings,
                      );
                    assert(false);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
