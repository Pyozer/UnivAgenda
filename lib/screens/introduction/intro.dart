import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:myagenda/utils/preferences.dart';

class IntroductionScreen extends StatelessWidget {
  final pages = [
    new PageViewModel(
        pageColor: const Color(0xFF03A9F4),
        iconImageAssetPath: 'assets/air-hostess.png',
        iconColor: null,
        bubbleBackgroundColor: null,
        body: Text(
          'Haselfree  booking  of  flight  tickets  with  full  refund  on  cancelation',
        ),
        title: Text(
          'Title 1',
        ),
        textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        mainImage: Image.asset(
          'assets/airplane.png',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        )),
    new PageViewModel(
      pageColor: const Color(0xFF8BC34A),
      iconImageAssetPath: 'assets/waiter.png',
      iconColor: null,
      bubbleBackgroundColor: null,
      body: Text(
        'We  work  for  the  comfort ,  enjoy  your  stay  at  our  beautiful  hotels',
      ),
      title: Text('Title 2'),
      mainImage: Image.asset(
        'assets/hotel.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
    new PageViewModel(
      pageColor: const Color(0xFF607D8B),
      iconImageAssetPath: 'assets/taxi-driver.png',
      iconColor: null,
      bubbleBackgroundColor: null,
      body: Text(
        'Easy  cab  booking  at  your  doorstep  with  cashless  payment  system',
      ),
      title: Text('Title 3'),
      mainImage: Image.asset(
        'assets/taxi.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
  ];

  void _onDone(BuildContext context) async {
    await Preferences.setFirstBoot(false);
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return new IntroViewsFlutter(
      pages,
      onTapDoneButton: () => _onDone(context),
      showSkipButton: true, //Whether you want to// show the skip button or not.
      pageButtonTextStyles: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      ),
    ); //Material App
  }
}
