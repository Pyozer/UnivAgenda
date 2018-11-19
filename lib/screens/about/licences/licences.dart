import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/licence.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/widgets/settings/list_tile_title.dart';

class LicencesScreen extends StatelessWidget {
  static const git = "https://github.com/";

  static const List<Licence> _libraries = [
    Licence(
      "Cupertino Icons",
      "Flutter Team",
      license: "MIT Licence",
      url: "${git}flutter/cupertino_icons",
    ),
    Licence(
      "Firebase Analytics",
      "Flutter Team",
      license: "BSD Licence",
      url: "${git}flutter/plugins/tree/master/packages/firebase_analytics",
    ),
    Licence(
      "Flutter Launcher Icons",
      "Flutter Community, Franz Silva, Mark O'Sullivan",
      license: "MIT Licence",
      url: "${git}fluttercommunity/flutter_launcher_icons",
    ),
    Licence(
      "Flutter Markdown",
      "Flutter Authors",
      url: "${git}flutter/flutter_markdown",
    ),
    Licence(
      "Flutter Material Color Picker",
      "Jean-Charles Moussé",
      license: "MIT Licence",
      url: "${git}Pyozer/color_picker",
    ),
    Licence(
      "HTML",
      "Dart Team",
      license: "MIT Licence",
      url: "${git}dart-lang/html",
    ),
    Licence(
      "HTTP",
      "Dart project authors",
      license: "BSD 3-Clause Licence",
      url: "${git}dart-lang/http",
    ),
    Licence(
      "Introduction Screen",
      "Jean-Charles Moussé",
      license: "MIT Licence",
      url: "${git}Pyozer/introduction_screen",
    ),
    Licence(
      "Outline Material Icons",
      "Lucas Levin",
      license: "Apache 2.0",
      url: "${git}lucaslcode/outline_material_icons",
    ),
    Licence(
      "Path Provider",
      "Flutter Team",
      license: "BSD",
      url: "${git}flutter/plugins/tree/master/packages/path_provider",
    ),
    Licence(
      "Shared Preferences",
      "Flutter Team",
      license: "BSD Licence",
      url: "${git}flutter/plugins/tree/master/packages/shared_preferences",
    ),
    Licence(
      "Time Machine",
      "Dana Ferguson",
      license: "Apache 2.0",
      url: "${git}Dana-Ferguson/time_machine",
    ),
    Licence(
      "URL Launcher",
      "Flutter Team",
      license: "BSD Licence",
      url: "${git}flutter/plugins/tree/master/packages/url_launcher",
    ),
    Licence(
      "UUID",
      "Yulian Kuncheff",
      license: "MIT",
      url: "${git}Daegalus/dart-uuid",
    ),
  ];

  List<Widget> _buildList(BuildContext context) {
    return _libraries.map((l) {
      return ListTile(
        title: ListTileTitle(l.library),
        subtitle: Text(l.author),
        trailing: l.license.isNotEmpty ? Text(l.license) : const Text(''),
        onTap: l.url != null ? () => openLink(context, l.url, l.library) : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      title: FlutterI18n.translate(context, StrKey.OPENSOURCE_LICENCES),
      body: Container(
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: _buildList(context),
          ).toList(growable: false),
        ),
      ),
    );
  }
}
