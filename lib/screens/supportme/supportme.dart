import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/utils/translations.dart';

const String testDevice = '9b34e796f34721de'; // OnePlus3

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

  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices: <String>[testDevice],
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    birthday: new DateTime.now(),
    childDirected: true,
    gender: MobileAdGender.male,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;

  BannerAd createBannerAd() {
    return new BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.largeBanner,
      targetingInfo: targetingInfo,
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: appId);

    _bannerAd = createBannerAd()
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    return AppbarPage(
      title: translations.get(StringKey.SUPPORTME),
      body: Container(),
    );
  }
}
