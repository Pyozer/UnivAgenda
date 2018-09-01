import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(64.0),
        child: SingleChildScrollView(
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    Asset.LOGO,
                    width: 120.0,
                  ),
                  Container(height: 12.0,),
                  Text("MyAgenda", style: Theme.of(context).textTheme.title.copyWith(fontSize: 28.0),),
                  Container(height: 64.0,),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Identifiant"
                    ),
                  ),
                  Container(height: 24.0,),
                  TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Mot de passe"
                    ),
                  )
                ],
              ),
            ),
        ),
      )
    );
  }
}
