import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:univagenda/screens/splashscreen/splashscreen.dart';
import 'package:univagenda/utils/preferences/settings.provider.dart';
import 'package:univagenda/utils/preferences/theme.provider.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(
          value: SettingsProvider.instance,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(
          value: ThemeProvider.instance,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, prefs, _) {
          ThemeMode themeMode = prefs.darkTheme ? ThemeMode.dark : ThemeMode.light;

          SystemUiOverlayStyle style = prefs.darkTheme
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark;

          SystemChrome.setSystemUIOverlayStyle(style.copyWith(
            statusBarColor: Colors.transparent,
          ));

          return MaterialApp(
            title: "UnivAgenda",
            themeMode: themeMode,
            theme: ThemeData(
                brightness: Brightness.light,
                fontFamily: 'GoogleSans',
                primaryColor: prefs.primaryColor,
                toggleableActiveColor: prefs.accentColor,
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: prefs.accentColor,
                ),
                colorScheme: ColorScheme.light(
                  primary: prefs.primaryColor,
                  secondary: prefs.accentColor,
                  // primaryContainer: CustomColors.affMainBlue2,
                  // secondaryContainer: CustomColors.affDarkBlue,
                  // error: CustomColors.affRedError,
                  // onPrimary: Colors.white,
                  // surface: Colors.white,
                ),
                // errorColor: CustomColors.affRedError,
                // toggleableActiveColor: CustomColors.affMainBlue,
                textButtonTheme: TextButtonThemeData(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.black,
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                )),
            darkTheme: ThemeData(
                brightness: Brightness.dark,
                fontFamily: 'GoogleSans',
                primaryColor: prefs.primaryColor,
                toggleableActiveColor: prefs.accentColor,
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: prefs.accentColor,
                ),
                colorScheme: ColorScheme.dark(
                  primary: prefs.primaryColor,
                  secondary: prefs.accentColor,
                  // primaryContainer: CustomColors.affMainBlue2,
                  // secondaryContainer: CustomColors.affDarkBlue,
                  // error: CustomColors.affRedError,
                  // onPrimary: Colors.white,
                  // surface: Colors.white,
                ),
                // errorColor: CustomColors.affRedError,
                // toggleableActiveColor: CustomColors.affMainBlue,
                textButtonTheme: TextButtonThemeData(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                )),
            localizationsDelegates: [
              ...GlobalMaterialLocalizations.delegates,
              SfGlobalLocalizations.delegate
            ],
            supportedLocales: i18n.supportedLocales(),
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
