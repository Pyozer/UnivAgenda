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
  Widget _buildHeader(BuildContext context) {
    final txtTheme =
        Theme.of(context).textTheme.headline.copyWith(fontSize: 30.0);

    return Container(
        padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Image.asset(Asset.LOGO, width: 80.0)),
              Text(Translations.of(context).get(StringKey.APP_NAME),
                  style: txtTheme),
            ]));
  }

  Widget _buildWhatIsIt(BuildContext context) {
    return AboutCard(
      title: Translations.of(context).get(StringKey.WHAT_IS_IT),
      children: <Widget>[
        Text(
          Translations.of(context).get(StringKey.ABOUT_WHAT),
          style: Theme.of(context).textTheme.body1,
          textAlign: TextAlign.justify,
        )
      ],
    );
  }

  Widget _buildAuthor(BuildContext context) {
    final translation = Translations.of(context);
    return AboutCard(
      title: translation.get(StringKey.AUTHOR),
      lateralPadding: false,
      children: <Widget>[
        ListTile(
            leading:
                CircleImage(image: Image.asset(Asset.PICTURE_JC, width: 45.0)),
            title: Text("Jean-Charles Moussé"),
            subtitle: Text(translation.get(StringKey.DEVELOPER)),
            onTap: () {
              openLink("https://pyozer.github.io");
            })
      ],
    );
  }

  Widget _buildSocial(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final translation = Translations.of(context);

    return AboutCard(
      title: translation.get(StringKey.SOCIAL),
      lateralPadding: false,
      children: <Widget>[
        ListTile(
          leading: Image.asset(isDark ? Asset.GITHUB_WHITE : Asset.GITHUB_DARK,
              width: 30.0),
          title: Text(translation.get(StringKey.GITHUB_PROJECT)),
          onTap: () {
            openLink("https://github.com/pyozer/myagenda_flutter");
          },
        ),
        ListTile(
          leading: Image.asset(
              isDark ? Asset.TWITTER_WHITE : Asset.TWITTER_BLUE,
              width: 30.0),
          title: Text("Twitter"),
          onTap: () {
            openLink("https://twitter.com/jc_mousse");
          },
        )
      ],
    );
  }

  Widget _buildOther(BuildContext context) {
    final translation = Translations.of(context);
    return AboutCard(
        title: translation.get(StringKey.OTHER),
        lateralPadding: false,
        children: <Widget>[
          ListTile(
              title: Text(translation.get(StringKey.CHANGELOG)),
              subtitle: Text(translation.get(StringKey.CHANGELOG_DESC)),
              onTap: () => _modalBottomSheet(context)),
          ListTile(
              title: Text(translation.get(StringKey.OPENSOURCE_LICENCES)),
              subtitle:
                  Text(translation.get(StringKey.OPENSOURCE_LICENCES_DESC)),
              onTap: () {
                //showLicensePage(context: context, applicationIcon: Image.asset(Asset.LOGO), applicationName: "MyAgenda", applicationVersion: "1.0.0");
                Navigator.pushNamed(context, RouteKey.LICENCES);
              }),
          ListTile(
              title: Text(translation.get(StringKey.VERSION)),
              subtitle: Text("1.0.0"))
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
                  child: Text(Translations.of(context).get(StringKey.CHANGELOG),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 24.0)),
                ),
                Expanded(child: ChangeLog())
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return AppbarPage(
        title: translations.get(StringKey.ABOUT),
        body: Container(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[200]
                : null,
            child: ListView(
              children: [
                _buildHeader(context),
                _buildWhatIsIt(context),
                _buildAuthor(context),
                _buildSocial(context),
                _buildOther(context),
                _buildFooter(context),
              ],
            )));
  }
}
