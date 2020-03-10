import 'package:flutter/material.dart';
import 'Settings/Authentication.dart';
import 'package:provider/provider.dart';
import 'Settings/theme.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';

Future<bool>_loginState;

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Auth _auth = Auth();
  Widget login;
  Future<bool> loginState() async{
    login = await _auth.isLoggedIn();
    return true;
  }
  MaterialAppWithTheme(){
    _loginState = loginState();
  }
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
return Container(
    child:FutureBuilder(
        future: _loginState,
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
          return MaterialApp(
              theme: theme.getTheme(),
              title: 'STDY',
              home: SplashScreen.navigate(
                name: 'assets/intro.flr',
                next: (_) {
                  return login;
                },
                until: () => Future.delayed(Duration(seconds: 1)),
                startAnimation: 'intro',
              )
          );
          }
          else return Container();}
    ));
  }
}