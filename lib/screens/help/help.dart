import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/models/help_item.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/help/help_details.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/widgets/ui/no_result_help.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<HelpItem>> _loadHelpData(String lang) async {
    final response = await HttpRequest.get(Url.helpList);

    if (!response.isSuccess) throw Exception();

    List responseJson = json.decode(response.httpResponse.body);

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
            fullscreenDialog: true,
          ),
        );
      },
    );
  }

  void _sendFeedback(BuildContext context) async {
    var url = 'mailto:jeancharles.msse@gmail.com?subject=Feedback MyAgenda';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _scaffoldKey?.currentState?.showSnackBar(
        SnackBar(
            content:
                Text(FlutterI18n.translate(context, StrKey.NO_EMAIL_APP))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang =
        Localizations.localeOf(context).languageCode?.substring(0, 2) ?? "en";

    return AppbarPage(
      scaffoldKey: _scaffoldKey,
      title: FlutterI18n.translate(context, StrKey.HELP_FEEDBACK),
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

                  if (snapshot.hasError) return const NoResultHelp();

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
              child: RaisedButtonColored(
                onPressed: () => _sendFeedback(context),
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 40.0,
                ),
                text: FlutterI18n.translate(context, StrKey.SEND_FEEDBACK)
                    .toUpperCase(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
