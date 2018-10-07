import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/models/analytics.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/changelog.dart';
import 'package:myagenda/widgets/images/circle_image.dart';
import 'package:myagenda/widgets/ui/about_card.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class AboutScreen extends StatelessWidget {
  Widget _buildHeader(BuildContext context) {
    final txtTheme =
        Theme.of(context).textTheme.headline.copyWith(fontSize: 30.0);
    final appName = Translations.of(context).get(StringKey.APP_NAME);

    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Hero(
              tag: Asset.LOGO,
              child: Image.asset(Asset.LOGO, width: 80.0),
            ),
          ),
          Text(appName, style: txtTheme),
        ],
      ),
    );
  }

  Widget _buildWhatIsIt(BuildContext context) {
    final translations = Translations.of(context);
    return AboutCard(
      title: translations.get(StringKey.WHAT_IS_IT),
      children: <Widget>[
        Text(
          translations.get(StringKey.ABOUT_WHAT),
          style: Theme.of(context).textTheme.body1,
          textAlign: TextAlign.justify,
        )
      ],
    );
  }

  Widget _buildAuthor(BuildContext context) {
    final translations = Translations.of(context);

    return AboutCard(
      title: translations.get(StringKey.AUTHOR),
      lateralPadding: false,
      children: <Widget>[
        ListTile(
          leading: CircleImage(
            image: Image.asset(Asset.PICTURE_JC, width: 45.0),
          ),
          title: const Text("Jean-Charles Moussé"),
          subtitle: Text(translations.get(StringKey.DEVELOPER)),
          onTap: () => openLink(
                context,
                Url.myWebsite,
                AnalyticsValue.websiteJC,
              ),
        ),
        ListTile(
          leading: CircleImage(
            image: Image.asset(Asset.PICTURE_JUSTIN, width: 45.0),
          ),
          title: const Text("Justin Martin"),
          subtitle: Text(
            "${translations.get(StringKey.DEVELOPER)}, ${translations.get(StringKey.RIGHTS)}",
          ),
        )
      ],
    );
  }

  Widget _buildSocial(BuildContext context) {
    final isDark = isDarkTheme(Theme.of(context).brightness);
    final translations = Translations.of(context);

    return AboutCard(
      title: Translations.of(context).get(StringKey.SOCIAL),
      lateralPadding: false,
      children: <Widget>[
        ListTile(
          leading: Image.asset(
            Platform.isAndroid ? Asset.PLAYSTORE : Asset.APPSTORE,
            width: Platform.isAndroid ? 30.0 : 32.0,
          ),
          title: Text(Platform.isAndroid ? "Play Store" : "App Store"),
          subtitle: Text(translations.get(StringKey.ADD_NOTE_STORE)),
          onTap: () => openLink(
                context,
                Platform.isAndroid ? Url.playstore : Url.appstore,
                AnalyticsValue.store,
              ),
        ),
        ListTile(
          leading: Image.asset(
            isDark ? Asset.GITHUB_WHITE : Asset.GITHUB_DARK,
            width: 30.0,
          ),
          title: Text(translations.get(StringKey.GITHUB_PROJECT)),
          subtitle: Text(translations.get(StringKey.GITHUB_PROJECT_DESC)),
          onTap: () => openLink(
                context,
                Url.githubProjet,
                AnalyticsValue.github,
              ),
        ),
        ListTile(
          leading: Image.asset(
            isDark ? Asset.TWITTER_WHITE : Asset.TWITTER_BLUE,
            width: 30.0,
          ),
          title: const Text("Twitter"),
          subtitle: Text(translations.get(StringKey.TWITTER_DESC)),
          onTap: () => openLink(context, Url.myTwitter, AnalyticsValue.twitter),
        ),
      ],
    );
  }

  Widget _buildOther(BuildContext context, VoidCallback onChangeLogTap,
      VoidCallback onLicensesTap) {
    final translations = Translations.of(context);

    return AboutCard(
        title: translations.get(StringKey.OTHER),
        lateralPadding: false,
        children: <Widget>[
          ListTile(
            title: Text(translations.get(StringKey.CHANGELOG)),
            subtitle: Text(translations.get(StringKey.CHANGELOG_DESC)),
            onTap: onChangeLogTap,
          ),
          ListTile(
            title: Text(translations.get(StringKey.OPENSOURCE_LICENCES)),
            subtitle:
                Text(translations.get(StringKey.OPENSOURCE_LICENCES_DESC)),
            onTap: onLicensesTap,
          ),
          ListTile(
              title: Text(translations.get(StringKey.VERSION)),
              subtitle: const Text("4.0.1"))
        ]);
  }

  Widget _buildFooter(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme.subhead;

    return Container(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(Translations.of(context).get(StringKey.MADE_WITH),
                  style: txtTheme),
              Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: const Icon(OMIcons.favorite, color: Colors.red))
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
                  child: Text(
                    Translations.of(context).get(StringKey.CHANGELOG),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 24.0),
                  ),
                ),
                Expanded(child: ChangeLog())
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    final theme = Theme.of(context);

    return AppbarPage(
      title: translations.get(StringKey.ABOUT),
      body: Container(
        color: !isDarkTheme(theme.brightness) ? Colors.grey[200] : null,
        child: ListView(
          children: [
            _buildHeader(context),
            _buildWhatIsIt(context),
            _buildAuthor(context),
            _buildSocial(context),
            _buildOther(
              context,
              () => _modalBottomSheet(context),
              () => Navigator.pushNamed(context, RouteKey.LICENCES),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }
}
