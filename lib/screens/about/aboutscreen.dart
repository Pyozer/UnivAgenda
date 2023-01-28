import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:univagenda/keys/assets.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/keys/url.dart';
import 'package:univagenda/models/analytics.dart';
import 'package:univagenda/screens/about/licences/licences.dart';
import 'package:univagenda/screens/appbar_screen.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/changelog.dart';
import 'package:univagenda/widgets/images/circle_image.dart';
import 'package:univagenda/widgets/ui/about_card.dart';
import 'package:univagenda/widgets/ui/logo.dart';

class AboutScreen extends StatelessWidget {
  Widget _buildHeader(BuildContext context) {
    final txtTheme =
        Theme.of(context).textTheme.headline5!.copyWith(fontSize: 30.0);
    final appName = i18n.text(StrKey.APP_NAME);

    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Logo(size: 80.0),
          ),
          Text(appName, style: txtTheme),
        ],
      ),
    );
  }

  Widget _buildWhatIsIt(BuildContext context) {
    return AboutCard(
      title: i18n.text(StrKey.WHAT_IS_IT),
      children: [
        Text(
          i18n.text(StrKey.ABOUT_WHAT),
          style: Theme.of(context).textTheme.bodyText2,
          textAlign: TextAlign.justify,
        )
      ],
    );
  }

  Widget _buildAuthor(BuildContext context) {
    return AboutCard(
      title: i18n.text(StrKey.AUTHOR),
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
          subtitle: Text(i18n.text(StrKey.DEVELOPER)),
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
            "${i18n.text(StrKey.DEVELOPER)}, ${i18n.text(StrKey.RIGHTS)}",
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
    final isDark = context.isDark;
    final store = Platform.isAndroid ? "Play Store" : "App Store";

    return AboutCard(
      title: i18n.text(StrKey.SOCIAL),
      lateralPadding: false,
      children: [
        ListTile(
          leading: Image.asset(
            Platform.isAndroid ? Asset.PLAYSTORE : Asset.APPSTORE,
            width: Platform.isAndroid ? 30.0 : 32.0,
            semanticLabel: store,
          ),
          title: Text(store),
          subtitle: Text(i18n.text(StrKey.ADD_NOTE_STORE)),
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
          title: Text(i18n.text(StrKey.GITHUB_PROJECT)),
          subtitle: Text(
            i18n.text(StrKey.GITHUB_PROJECT_DESC),
          ),
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
          subtitle: Text(i18n.text(StrKey.TWITTER_DESC)),
          onTap: () => openLink(context, Url.myTwitter, AnalyticsValue.twitter),
        ),
      ],
    );
  }

  String getAppInfo(PackageInfo? info) {
    if (info == null) return "...";
    String str = info.version;
    if (info.buildNumber.isNotEmpty) str += " (${info.buildNumber})";
    return str;
  }

  Widget _buildOther(BuildContext context, VoidCallback onChangeLogTap,
      VoidCallback onLicensesTap) {
    return AboutCard(
      title: i18n.text(StrKey.OTHER),
      lateralPadding: false,
      children: [
        ListTile(
          title: Text(i18n.text(StrKey.CHANGELOG)),
          subtitle: Text(i18n.text(StrKey.CHANGELOG_DESC)),
          onTap: onChangeLogTap,
        ),
        ListTile(
          title: Text(i18n.text(StrKey.OPENSOURCE_LICENCES)),
          subtitle: Text(i18n.text(StrKey.OPENSOURCE_LICENCES_DESC)),
          onTap: onLicensesTap,
        ),
        ListTile(
          title: Text(i18n.text(StrKey.VERSION)),
          subtitle: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (_, snapshot) => Text(getAppInfo(snapshot.data)),
          ),
        )
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme.subtitle1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(i18n.text(StrKey.MADE_WITH), style: txtTheme),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: const Icon(Icons.favorite_outline, color: Colors.red),
          ),
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
                i18n.text(StrKey.CHANGELOG),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24.0,
                ),
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
    AnalyticsProvider.setScreen(this);

    return AppbarPage(
      title: i18n.text(StrKey.ABOUT),
      body: Container(
        child: ListView(
          children: [
            _buildHeader(context),
            _buildWhatIsIt(context),
            _buildAuthor(context),
            _buildSocial(context),
            _buildOther(
              context,
              () => _modalBottomSheet(context),
              () => navigatorPush(context, LicencesScreen()),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }
}
