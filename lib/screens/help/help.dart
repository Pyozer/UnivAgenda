import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/models/help_item.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/help/help_details.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/button/large_rounded_button.dart';
import 'package:myagenda/widgets/ui/screen_message/no_result_help.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<HelpItem>> _loadHelpData() async {
    final response = await HttpRequest.get(Url.helpList);

    if (!response.isSuccess) throw Exception();

    List responseJson = json.decode(response.httpResponse.body);

    return responseJson
        .map((itemJson) => HelpItem.fromJson(itemJson, i18n.currentLanguage))
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
      _scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(i18n.text(StrKey.NO_EMAIL_APP)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsProvider.setScreen(this);
    
    return AppbarPage(
      scaffoldKey: _scaffoldKey,
      title: i18n.text(StrKey.HELP_FEEDBACK),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<HelpItem>>(
                future: _loadHelpData(),
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
            Hero(
              tag: "fabBtn",
              child: LargeRoundedButton(
                onPressed: () => _sendFeedback(context),
                text: i18n.text(StrKey.SEND_FEEDBACK),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
