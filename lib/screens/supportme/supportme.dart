import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/raised_button_colored.dart';

const testDevices = [
  '9b34e796f34721de',
]; // Android Emulator

class SupportMeScreen extends StatefulWidget {
  _SupportMeScreenState createState() => _SupportMeScreenState();
}

class _SupportMeScreenState extends State<SupportMeScreen> {
  static final String appId = Platform.isAndroid
      ? 'ca-app-pub-4423812191493105~7454106275'
      : 'ca-app-pub-4423812191493105~7975305867';

  static final String bannerID = Platform.isAndroid
      ? 'ca-app-pub-4423812191493105/9268206230'
      : 'ca-app-pub-4423812191493105/2910681446';

  static final String interstitialID = Platform.isAndroid
      ? 'ca-app-pub-4423812191493105/1763398535'
      : 'ca-app-pub-4423812191493105/3775867097';

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  static final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevices,
    childDirected: true,
    nonPersonalizedAds: true,
  );

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: appId);

    _bannerAd = BannerAd(
      adUnitId: bannerID,
      size: AdSize.largeBanner,
      targetingInfo: targetingInfo,
    )
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _openFullAd() async {
    _interstitialAd?.dispose();

    _interstitialAd = InterstitialAd(
      adUnitId: interstitialID,
      targetingInfo: targetingInfo,
    );
    _interstitialAd
      ..load()
      ..show();

    AnalyticsProvider.of(context).analytics.logEvent(
      name: 'open_fullad',
      parameters: <String, dynamic>{},
    );
  }

  void _openPayPal() async {
    final url = "https://paypal.me/jeancharlesmousse";
    try {
      await openLink(url);
    } catch (_) {
      _showSnackBar(
        Translations.of(context).get(StringKey.SUPPORTME_PAYPAL_ERROR) + url,
      );
    }
    AnalyticsProvider.of(context).analytics.logEvent(
      name: 'open_paypal',
      parameters: <String, dynamic>{},
    );
  }

  void _showSnackBar(String msg) {
    _scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    return AppbarPage(
      scaffoldKey: _scaffoldKey,
      title: translations.get(StringKey.SUPPORTME),
      body: Container(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: <Widget>[
            Text(
              translations.get(StringKey.SUPPORTME_HEADER),
              style: Theme.of(context).textTheme.display1,
            ),
            const SizedBox(height: 24.0),
            Text(
              translations.get(StringKey.SUPPORTME_TEXT),
              style: Theme.of(context).textTheme.subhead,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24.0),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16.0,
              children: <Widget>[
                RaisedButtonColored(
                  text: translations.get(StringKey.SUPPORTME_AD).toUpperCase(),
                  onPressed: _openFullAd,
                ),
                RaisedButtonColored(
                  text: translations
                      .get(StringKey.SUPPORTME_HEADER)
                      .toUpperCase(),
                  onPressed: _openPayPal,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
