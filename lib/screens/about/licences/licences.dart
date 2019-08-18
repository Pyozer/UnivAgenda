import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/licence.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/settings/list_tile_title.dart';

class LicencesScreen extends StatelessWidget {
  static const git = "https://github.com/";

  static List<Licence> _libraries = [
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
      "Flutter Calendar",
      "Eric Windmill / Jean-Charles Moussé",
      license: "BSD Licence",
      url: "${git}pyozer/flutter_calendar",
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
      "Package Info",
      "Flutter Team",
      license: "BSD",
      url: "${git}flutter/plugins/tree/master/packages/package_info",
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
      "Timezone",
      "Boris Kaul / Sam Rawlins",
      license: "BSD Licence",
      url: "${git}srawlins/timezone",
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
    _libraries.sort((a, b) => a.library.compareTo(b.library));
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
    AnalyticsProvider.setScreen(this);

    return AppbarPage(
      title: i18n.text(StrKey.OPENSOURCE_LICENCES),
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
