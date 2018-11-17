import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/models/analytics.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/widgets/changelog.dart';
import 'package:myagenda/widgets/images/circle_image.dart';
import 'package:myagenda/widgets/ui/about_card.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class AboutScreen extends StatelessWidget {
  Widget _buildHeader(BuildContext context) {
    final txtTheme =
        Theme.of(context).textTheme.headline.copyWith(fontSize: 30.0);
    final appName = FlutterI18n.translate(context, StrKey.APP_NAME);

    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Hero(
              tag: Asset.LOGO,
              child: Image.asset(
                Asset.LOGO,
                width: 80.0,
                semanticLabel: "Logo",
              ),
            ),
          ),
          Text(appName, style: txtTheme),
        ],
      ),
    );
  }

  Widget _buildWhatIsIt(BuildContext context) {
    return AboutCard(
      title: FlutterI18n.translate(context, StrKey.WHAT_IS_IT),
      children: [
        Text(
          FlutterI18n.translate(context, StrKey.ABOUT_WHAT),
          style: Theme.of(context).textTheme.body1,
          textAlign: TextAlign.justify,
        )
      ],
    );
  }

  Widget _buildAuthor(BuildContext context) {
    return AboutCard(
      title: FlutterI18n.translate(context, StrKey.AUTHOR),
      lateralPadding: false,
      children: [
        ListTile(
          leading: CircleImage(
            image: Image.asset(
              Asset.PICTURE_JC,
              width: 45.0,
              semanticLabel: "Photo Jean-Charles Moussé",
            ),
          ),
          title: const Text("Jean-Charles Moussé"),
          subtitle: Text(FlutterI18n.translate(context, StrKey.DEVELOPER)),
          onTap: () => openLink(
                context,
                Url.myWebsite,
                AnalyticsValue.websiteJC,
              ),
        ),
        ListTile(
          leading: CircleImage(
            image: Image.asset(
              Asset.PICTURE_JUSTIN,
              width: 45.0,
              semanticLabel: "Photo Justin Martin",
            ),
          ),
          title: const Text("Justin Martin"),
          subtitle: Text(
            "${FlutterI18n.translate(context, StrKey.DEVELOPER)}, ${FlutterI18n.translate(context, StrKey.RIGHTS)}",
          ),
          onTap: () => openLink(
                context,
                Url.justinWebsite,
                AnalyticsValue.websiteJustin,
              ),
        )
      ],
    );
  }

  Widget _buildSocial(BuildContext context) {
    final isDark = isDarkTheme(Theme.of(context).brightness);

    final store = Platform.isAndroid ? "Play Store" : "App Store";

    return AboutCard(
      title: FlutterI18n.translate(context, StrKey.SOCIAL),
      lateralPadding: false,
      children: [
        ListTile(
          leading: Image.asset(
            Platform.isAndroid ? Asset.PLAYSTORE : Asset.APPSTORE,
            width: Platform.isAndroid ? 30.0 : 32.0,
            semanticLabel: store,
          ),
          title: Text(store),
          subtitle:
              Text(FlutterI18n.translate(context, StrKey.ADD_NOTE_STORE)),
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
            semanticLabel: "Logo GitHub",
          ),
          title: Text(FlutterI18n.translate(context, StrKey.GITHUB_PROJECT)),
          subtitle: Text(
              FlutterI18n.translate(context, StrKey.GITHUB_PROJECT_DESC)),
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
            semanticLabel: "Logo Twitter",
          ),
          title: const Text("Twitter"),
          subtitle:
              Text(FlutterI18n.translate(context, StrKey.TWITTER_DESC)),
          onTap: () => openLink(context, Url.myTwitter, AnalyticsValue.twitter),
        ),
      ],
    );
  }

  Widget _buildOther(BuildContext context, VoidCallback onChangeLogTap,
      VoidCallback onLicensesTap) {
    return AboutCard(
        title: FlutterI18n.translate(context, StrKey.OTHER),
        lateralPadding: false,
        children: [
          ListTile(
            title: Text(FlutterI18n.translate(context, StrKey.CHANGELOG)),
            subtitle:
                Text(FlutterI18n.translate(context, StrKey.CHANGELOG_DESC)),
            onTap: onChangeLogTap,
          ),
          ListTile(
            title: Text(
                FlutterI18n.translate(context, StrKey.OPENSOURCE_LICENCES)),
            subtitle: Text(FlutterI18n.translate(
                context, StrKey.OPENSOURCE_LICENCES_DESC)),
            onTap: onLicensesTap,
          ),
          ListTile(
              title: Text(FlutterI18n.translate(context, StrKey.VERSION)),
              subtitle: const Text("4.0.5"))
        ]);
  }

  Widget _buildFooter(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme.subhead;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            FlutterI18n.translate(context, StrKey.MADE_WITH),
            style: txtTheme,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: const Icon(OMIcons.favorite, color: Colors.red),
          )
        ],
      ),
    );
  }

  //It doesn't need any key , we can easily create it.
  void _modalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                FlutterI18n.translate(context, StrKey.CHANGELOG),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 24.0),
              ),
            ),
            Expanded(child: ChangeLog())
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppbarPage(
      title: FlutterI18n.translate(context, StrKey.ABOUT),
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
