import 'package:flutter/material.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/translate/string_key.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/widgets/about_card.dart';
import 'package:myagenda/widgets/circle_image.dart';
import 'package:myagenda/widgets/logo_app.dart';

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
                  child: LogoApp(width: 80.0)),
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
    return AboutCard(
      title: Translations.of(context).get(StringKey.AUTHOR),
      lateralPadding: false,
      children: <Widget>[
        ListTile(
            leading: CircleImage(
                image: Image.network(
                    "https://pyozer.github.io/static/media/img_profil.ca35ebef.png",
                    width: 50.0)),
            title: Text("Jean-Charles Moussé"),
            subtitle: Text(Translations.of(context).get(StringKey.DEVELOPER)))
      ],
    );
  }

  Widget _buildSocial(BuildContext context) {
    return AboutCard(
      title: Translations.of(context).get(StringKey.SOCIAL),
      lateralPadding: false,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text("GitHub Project"),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.accessible),
          title: Text("Twitter"),
          onTap: () {},
        )
      ],
    );
  }

  Widget _buildOther(BuildContext context) {
    return AboutCard(
      title: Translations.of(context).get(StringKey.OTHER),
      lateralPadding: false,
      children: <Widget>[
        ListTile(
            title: Text("Changelog"),
            subtitle: Text("See the changelog of the app")),
        ListTile(
            title: Text("Open source licences"),
            subtitle: Text("Licences details for open softwares")),
        ListTile(title: Text("Version"), subtitle: Text("1.0.0"))
      ],
    );
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
                  padding: EdgeInsets.only(left: 5.0),
                  child: const Icon(Icons.favorite, color: Colors.red))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return AppbarPage(
        title: translations.get(StringKey.ABOUT),
        body: Container(
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
