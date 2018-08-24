import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/changelog.dart';
import 'package:myagenda/widgets/images/circle_image.dart';
import 'package:myagenda/widgets/ui/about_card.dart';

class AboutScreen extends StatelessWidget {
  Translations _translations;
  ThemeData _theme;

  Widget _buildHeader() {
    final txtTheme = _theme.textTheme.headline.copyWith(fontSize: 30.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Image.asset(Asset.LOGO, width: 80.0)),
          Text(_translations.get(StringKey.APP_NAME), style: txtTheme),
        ],
      ),
    );
  }

  Widget _buildWhatIsIt() {
    return AboutCard(
      title: _translations.get(StringKey.WHAT_IS_IT),
      children: <Widget>[
        Text(
          _translations.get(StringKey.ABOUT_WHAT),
          style: _theme.textTheme.body1,
          textAlign: TextAlign.justify,
        )
      ],
    );
  }

  Widget _buildAuthor() {
    return AboutCard(
      title: _translations.get(StringKey.AUTHOR),
      lateralPadding: false,
      children: <Widget>[
        ListTile(
          leading:
              CircleImage(image: Image.asset(Asset.PICTURE_JC, width: 45.0)),
          title: Text("Jean-Charles Moussé"),
          subtitle: Text(_translations.get(StringKey.DEVELOPER)),
          onTap: () => openLink("https://pyozer.github.io"),
        )
      ],
    );
  }

  Widget _buildSocial() {
    final isDark = isDarkTheme(_theme.brightness);

    return AboutCard(
      title: _translations.get(StringKey.SOCIAL),
      lateralPadding: false,
      children: <Widget>[
        ListTile(
          leading: Image.asset(isDark ? Asset.GITHUB_WHITE : Asset.GITHUB_DARK,
              width: 30.0),
          title: Text(_translations.get(StringKey.GITHUB_PROJECT)),
          onTap: () => openLink("https://github.com/pyozer/myagenda_flutter"),
        ),
        ListTile(
          leading: Image.asset(
            isDark ? Asset.TWITTER_WHITE : Asset.TWITTER_BLUE,
            width: 30.0,
          ),
          title: Text("Twitter"),
          onTap: () => openLink("https://twitter.com/jc_mousse"),
        ),
      ],
    );
  }

  Widget _buildOther(VoidCallback onChangeLogTap, VoidCallback onLicensesTap) {
    return AboutCard(
        title: _translations.get(StringKey.OTHER),
        lateralPadding: false,
        children: <Widget>[
          ListTile(
            title: Text(_translations.get(StringKey.CHANGELOG)),
            subtitle: Text(_translations.get(StringKey.CHANGELOG_DESC)),
            onTap: onChangeLogTap,
          ),
          ListTile(
            title: Text(_translations.get(StringKey.OPENSOURCE_LICENCES)),
            subtitle:
                Text(_translations.get(StringKey.OPENSOURCE_LICENCES_DESC)),
            onTap: onLicensesTap,
          ),
          ListTile(
              title: Text(_translations.get(StringKey.VERSION)),
              subtitle: Text("1.0.0"))
        ]);
  }

  Widget _buildFooter() {
    final txtTheme = _theme.textTheme.subhead;

    return Container(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(_translations.get(StringKey.MADE_WITH), style: txtTheme),
              Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: const Icon(Icons.favorite, color: Colors.red))
            ]));
  }

  //It doesn't need any key , we can easily create it.
  void _modalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_translations.get(StringKey.CHANGELOG),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 24.0)),
                ),
                Expanded(child: ChangeLog())
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    _translations = Translations.of(context);
    _theme = Theme.of(context);

    return AppbarPage(
      title: _translations.get(StringKey.ABOUT),
      body: Container(
        color: !isDarkTheme(_theme.brightness) ? Colors.grey[200] : null,
        child: ListView(
          children: [
            _buildHeader(),
            _buildWhatIsIt(),
            _buildAuthor(),
            _buildSocial(),
            _buildOther(() => _modalBottomSheet(context),
                () => Navigator.pushNamed(context, RouteKey.LICENCES)),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
}
