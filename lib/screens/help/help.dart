import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../keys/string_key.dart';
import '../../models/help_item.dart';
import '../appbar_screen.dart';
import 'help_details.dart';
import '../../utils/analytics.dart';
import '../../utils/api/api.dart';
import '../../utils/functions.dart';
import '../../utils/translations.dart';
import '../../widgets/ui/button/large_rounded_button.dart';
import '../../widgets/ui/screen_message/no_result_help.dart';

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
