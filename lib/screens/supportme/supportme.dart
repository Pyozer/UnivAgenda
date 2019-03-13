import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/models/analytics.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/button/raised_button_colored.dart';

class SupportMeScreen extends StatefulWidget {
  _SupportMeScreenState createState() => _SupportMeScreenState();
}

class _SupportMeScreenState extends BaseState<SupportMeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
      _showSnackBar(i18n.text(errorKey) + url);
    }
  }

  void _showSnackBar(String msg) {
    _scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text(msg)));
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
              style: theme.textTheme.subhead.copyWith(fontSize: 18.0),
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
