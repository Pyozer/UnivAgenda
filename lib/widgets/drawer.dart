import 'package:flutter/material.dart';
import 'package:myagenda/translate/translations.dart';
import 'package:myagenda/widgets/logo_app.dart';

class MainDrawer extends StatelessWidget {

  const MainDrawer({ Key key }) : super(key: key);

  Widget _drawerElem(BuildContext context, IconData icon, Translate title, String routeDest) {
    return ListTile(
        leading: Icon(icon),
        title: Text(Translations.of(context).get(title)),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, routeDest);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
        semanticLabel: Translations.of(context).get(Translate.DRAWER),
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      LogoApp(width: 65.0),
                      Padding(padding: const EdgeInsets.only(top: 13.0)),
                      Text(
                          Translations.of(context).get(Translate.APP_NAME),
                          style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w500
                          )
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                  )
              ),
              _drawerElem(context, Icons.location_city, Translate.FINDROOM, '/findroom'),
              _drawerElem(context, Icons.settings, Translate.SETTINGS, '/settings'),
              _drawerElem(context, Icons.system_update, Translate.UPDATE, '/update'),
              _drawerElem(context, Icons.info_outline, Translate.ABOUT, '/about'),
              _drawerElem(context, Icons.lightbulb_outline, Translate.INTRO, '/intro'),
              _drawerElem(context, Icons.exit_to_app, Translate.LOGOUT, '/logout')
            ]
        )
    );
  }

}