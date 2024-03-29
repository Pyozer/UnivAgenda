import 'package:flutter/material.dart';

import '../../keys/string_key.dart';
import '../../keys/url.dart';
import '../../models/analytics.dart';
import '../appbar_screen.dart';
import '../../utils/analytics.dart';
import '../../utils/functions.dart';
import '../../utils/translations.dart';
import '../../widgets/ui/button/raised_button_colored.dart';

class SupportMeScreen extends StatefulWidget {
  const SupportMeScreen({Key? key}) : super(key: key);

  @override
  SupportMeScreenState createState() => SupportMeScreenState();
}

class SupportMeScreenState extends State<SupportMeScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsProvider.setScreen(widget);
  }

  void _openLydia() {
    _openLink(
      Url.lydia,
      i18n.text(StrKey.SUPPORTME_LINK_ERROR, {'link': 'Lydia'}),
      AnalyticsValue.lydia,
    );
  }

  void _openLink(String url, String errorKey, String analyticsEvent) async {
    try {
      await openLink(context, url, analyticsEvent);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(i18n.text(errorKey) + url)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      title: i18n.text(StrKey.SUPPORTME),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              i18n.text(StrKey.SUPPORTME_TEXT),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: 18.0),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24.0),
            Center(
              child: RaisedButtonColored(
                text: i18n.text(StrKey.SUPPORTME_LYDIA),
                onPressed: _openLydia,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
