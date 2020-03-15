import 'package:flutter/material.dart';
import '../../GoogleAPI/Authentication/Authentication.dart';
import 'package:provider/provider.dart';
import '../Subject/SettingsData.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';


//Creates an app with the theme
class ThemedApp extends StatelessWidget {

   Future<bool>_loginState;
  final Auth _auth = Auth();
   Widget _login;
  Future<bool> loginState() async{
    _login = await _auth.isLoggedIn();
    return true;
  }
  ThemedApp(){
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
              home: SplashScreen.navigate(//plays splash screen animation
                name: 'assets/intro.flr',
                next: (_) {
                  return _login;
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