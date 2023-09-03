import 'package:flutter/material.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/models/help_item.dart';
import 'package:univagenda/screens/appbar_screen.dart';
import 'package:univagenda/screens/help/help_details.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/api/api.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/ui/button/large_rounded_button.dart';
import 'package:univagenda/widgets/ui/screen_message/no_result_help.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  void _sendFeedback(BuildContext context) async {
    var url = 'mailto:jeancharles.msse@gmail.com?subject=Feedback UnivAgenda';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(i18n.text(StrKey.NO_EMAIL_APP)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsProvider.setScreen(this);

    return AppbarPage(
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
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return InkWell(
                        child: ListTile(title: Text(item.title)),
                        onTap: () {
                          navigatorPush(
                            context,
                            HelpDetailsScreen(helpItem: item),
                            fullscreenDialog: true,
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
            tag: 'fabBtn',
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
