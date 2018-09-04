import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/licence.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/translations.dart';

class LicencesScreen extends StatelessWidget {
  static const git = "https://github.com/";

  static const List<Licence> _libraries = [
    Licence("HTTP", "Dart project authors",
        license: "BSD 3-Clause Licence", url: "${git}dart-lang/http"),
    Licence("Flutter Markdown", "Flutter Authors",
        url: "${git}flutter/flutter_markdown"),
    Licence("Shared Preferences", "Flutter Team",
        license: "BSD Licence",
        url: "${git}flutter/plugins/tree/master/packages/shared_preferences"),
    Licence("Cupertino Icons", "Flutter Team",
        license: "MIT Licence", url: "${git}flutter/cupertino_icons"),
    Licence("URL Launcher", "Flutter Team",
        license: "BSD Licence",
        url: "${git}flutter/plugins/tree/master/packages/url_launcher"),
    Licence("Flutter Launcher Icons", "Flutter Community, Franz Silva, Mark O'Sullivan",
        license: "MIT Licence",
        url: "${git}fluttercommunity/flutter_launcher_icons"),
    Licence("Color Picker", "Jean-Charles Moussé",
        license: "MIT Licence", url: "${git}Pyozer/color_picker"),
    Licence("Dots Indicator", "Jean-Charles Moussé",
        license: "MIT Licence", url: "${git}Pyozer/dots_indicator"),
    Licence("Introduction Screen", "Jean-Charles Moussé",
        license: "MIT Licence", url: "${git}Pyozer/introduction_screen"),
  ];

  List<Widget> _buildList(BuildContext context) {
    final bool isDark = isDarkTheme(Theme.of(context).brightness);

    List<Widget> listLicenses = [];

    final libraryStyle = const TextStyle(fontWeight: FontWeight.w600);
    final authorStyle = TextStyle(color: Colors.grey[600]);
    final licenseStyle =
        TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[900]);

    for (final license in _libraries) {
      final libraryText = Text(license.library, style: libraryStyle);
      final authorText = Text(license.author, style: authorStyle);
      final licenseText = license.license.isNotEmpty
          ? Text(license.license, style: licenseStyle)
          : Text("");

      listLicenses.add(ListTile(
          title: libraryText,
          subtitle: authorText,
          trailing: licenseText,
          onTap: license.url != null ? () => openLink(license.url) : null));
    }

    return listLicenses;
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      title: Translations.of(context).get(StringKey.OPENSOURCE_LICENCES),
      body: Container(
        child: ListView(
            children: ListTile.divideTiles(
                    context: context, tiles: _buildList(context))
                .toList()),
      ),
    );
  }
}
