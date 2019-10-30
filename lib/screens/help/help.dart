import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/help_item.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/help/help_details.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/api/api.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/button/large_rounded_button.dart';
import 'package:myagenda/widgets/ui/screen_message/no_result_help.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<HelpItem>>(
              future: Api().getHelps(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const NoResultHelp();

                if (snapshot.hasData) {
                  return ListView.separated(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data[index];
                      return InkWell(
                        child: ListTile(title: Text(item.title)),
                        onTap: () {
                          Navigator.of(context).push(
                            CustomRoute(
                              builder: (_) => HelpDetailsScreen(helpItem: item),
                              fullscreenDialog: true,
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 0),
                  );
                }

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
    );
  }
}
