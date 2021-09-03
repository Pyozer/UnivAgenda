import 'package:flutter/material.dart';
import 'package:univagenda/keys/string_key.dart';
import 'package:univagenda/keys/url.dart';
import 'package:univagenda/models/analytics.dart';
import 'package:univagenda/screens/appbar_screen.dart';
import 'package:univagenda/screens/base_state.dart';
import 'package:univagenda/utils/analytics.dart';
import 'package:univagenda/utils/functions.dart';
import 'package:univagenda/utils/translations.dart';
import 'package:univagenda/widgets/ui/button/raised_button_colored.dart';

class SupportMeScreen extends StatefulWidget {
  _SupportMeScreenState createState() => _SupportMeScreenState();
}

class _SupportMeScreenState extends BaseState<SupportMeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    AnalyticsProvider.setScreen(widget);
  }

  void _openPayPal() {
    _openLink(
      Url.paypal,
      i18n.text(StrKey.SUPPORTME_LINK_ERROR, {'link': "Paypal"}),
      AnalyticsValue.paypal,
    );
  }

  void _openLink(String url, String errorKey, String analyticsEvent) async {
    try {
      await openLink(context, url, analyticsEvent);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(i18n.text(errorKey) + url)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      scaffoldKey: _scaffoldKey,
      title: i18n.text(StrKey.SUPPORTME),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              i18n.text(StrKey.SUPPORTME_TEXT),
              style: theme.textTheme.subtitle1!.copyWith(fontSize: 18.0),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24.0),
            Center(
              child: RaisedButtonColored(
                text: i18n.text(StrKey.SUPPORTME_PAYPAL),
                onPressed: _openPayPal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
