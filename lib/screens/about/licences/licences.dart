import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/licence.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/list_divider.dart';
import 'package:url_launcher/url_launcher.dart';

class LicencesScreen extends StatelessWidget {
  static const git = "https://github.com/";

  final List<Licence> _libraries = [
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
    Licence("Material Pickers", "Jake Wharton",
        url: "${git}long1eu/material_pickers"),
    Licence("Dots Indicator", "Jean-Charles Moussé",
        license: "MIT Licence", url: "${git}Pyozer/dots_indicator"),
    Licence("Introduction Screen", "Jean-Charles Moussé",
        license: "MIT Licence", url: "${git}Pyozer/introduction_screen"),
  ];

  Widget _buildList(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
        itemCount: _libraries.length * 2 - 1,
        itemBuilder: (context, index) {
          if (index.isOdd) return ListDivider();

          final license = _libraries[index ~/ 2];

          final libraryText = Text(license.library,
              style: TextStyle(fontWeight: FontWeight.w600));

          final authorText =
              Text(license.author, style: TextStyle(color: Colors.grey[600]));

          final licenseText = license.license.isNotEmpty
              ? Text(license.license,
                  style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[900]))
              : Text("");

          void _openLibraryURL() async {
            if (await canLaunch(license.url)) {
              await launch(license.url);
            } else {
              throw 'Could not launch ${license.url}';
            }
          }

          return ListTile(
              title: libraryText,
              subtitle: authorText,
              trailing: licenseText,
              onTap: license.url != null ? _openLibraryURL : null);
        });
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
        title: Translations.of(context).get(StringKey.OPENSOURCE_LICENCES),
        body: Container(child: _buildList(context)));
  }
}
