import 'package:flutter/material.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/translate/string_key.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/widgets/logo_app.dart';

class AboutScreen extends StatelessWidget {
  Widget _buildHeader(BuildContext context) {
    final txtTheme =
        Theme.of(context).textTheme.headline.copyWith(fontSize: 30.0);

    return Container(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: LogoApp(width: 70.0)),
          Text('MyAgenda', style: txtTheme),
        ]));
  }

  Widget _buildWhatIsIt(BuildContext context) {
    return AboutCard(
      title: "What is it ?",
      children: <Widget>[
        Text(
          "This app is linked to the agenda of th University of Le Mans. It allow you to have direct access to your calendar on your device without having to connect to the ENT.",
          style: Theme.of(context).textTheme.body1,
          textAlign: TextAlign.justify,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);

    return AppbarPage(
        title: translations.get(StringKey.ABOUT),
        body: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeader(context), _buildWhatIsIt(context)],
        )));
  }
}

class AboutCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const AboutCard({Key key, this.title, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> cardContent = [];
    cardContent.add(Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(title, style: Theme.of(context).textTheme.title)));
    cardContent.addAll(children);

    return Card(
      margin: EdgeInsets.all(16.0),
      shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(8.0))),
      child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cardContent,
          )),
    );
  }
}
