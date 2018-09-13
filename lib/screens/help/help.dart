import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/help_item.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/help/help_details.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:http/http.dart' as http;
import 'package:myagenda/widgets/ui/no_result.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';
import 'package:url_launcher/url_launcher.dart';

const kHelpDataUrl =
    "https://raw.githubusercontent.com/Pyozer/MyAgenda_Flutter/master/res/help/help_list.json";

class HelpScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<HelpItem>> _loadHelpData(String lang) async {
    final response = await http.get(kHelpDataUrl);

    if (response.statusCode != 200 || response.body.isEmpty) throw Exception();

    List responseJson = json.decode(response.body);

    return responseJson
        .map((itemJson) => HelpItem.fromJson(itemJson, lang))
        .toList();
  }

  Widget _buildItem(BuildContext context, HelpItem item) {
    return InkWell(
      child: ListTile(title: Text(item.title)),
      onTap: () {
        Navigator.of(context).push(
          CustomRoute(
              builder: (context) => HelpDetailsScreen(helpItem: item),
              fullscreenDialog: true),
        );
      },
    );
  }

  void _sendFeedback(BuildContext context) async {
    final translations = Translations.of(context);

    var url = 'mailto:jeancharles.msse@gmail.com?subject=Feedback MyAgenda';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _scaffoldKey?.currentState?.showSnackBar(
        SnackBar(
          content: Text(translations.get(StringKey.NO_EMAIL_APP)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    final lang = translations.locale.languageCode.substring(0, 2);

    return AppbarPage(
      scaffoldKey: _scaffoldKey,
      title: translations.get(StringKey.HELP_FEEDBACK),
      body: Container(
              child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<HelpItem>>(
                future: _loadHelpData(lang),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var helpItems = snapshot.data
                        .map((item) => _buildItem(context, item))
                        .toList();

                    return ListView(
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: helpItems,
                      ).toList(),
                    );
                  }

                  if (snapshot.hasError)
                    return NoResult(
                      title: "Aucune donnée",
                      text:
                          "Vérifiez votre connexion internet.\nIl se peut aussi que le serveur soit indisponible.",
                    );

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(height: 16.0),
            RaisedButtonColored(
              onPressed: () => _sendFeedback(context),
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 40.0,
              ),
              text: translations.get(StringKey.SEND_FEEDBACK).toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }
}
