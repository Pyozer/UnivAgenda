import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/keys/url.dart';
import 'package:myagenda/models/analytics.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';

class SupportMeScreen extends StatefulWidget {
  _SupportMeScreenState createState() => _SupportMeScreenState();
}

class _SupportMeScreenState extends BaseState<SupportMeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openPayPal() {
    _openLink(
      Url.paypal,
      StringKey.SUPPORTME_PAYPAL_ERROR,
      AnalyticsValue.paypal,
    );
  }

  void _openUnidays() {
    _openLink(
      Url.unidays,
      StringKey.SUPPORTME_PAYPAL_ERROR,
      AnalyticsValue.unidays,
    );
  }

  void _openLink(String url, String errorKey, String analyticsEvent) async {
    try {
      await openLink(context, url, analyticsEvent);
    } catch (_) {
      _showSnackBar(translations.get(errorKey) + url);
    }
  }

  void _showSnackBar(String msg) {
    _scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AppbarPage(
      scaffoldKey: _scaffoldKey,
      title: translations.get(StringKey.SUPPORTME),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: <Widget>[
              Text(
                translations.get(StringKey.SUPPORTME_TEXT),
                style: theme.textTheme.subhead,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24.0),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 8.0,
                runSpacing: 8.0,
                children: <Widget>[
                  RaisedButtonColored(
                    text: translations.get(StringKey.SUPPORTME_UNIDAYS),
                    onPressed: _openUnidays,
                  ),
                  RaisedButtonColored(
                    text: translations.get(StringKey.SUPPORTME_HEADER),
                    onPressed: _openPayPal,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
