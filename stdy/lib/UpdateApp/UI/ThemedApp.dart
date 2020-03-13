import 'package:flutter/material.dart';
import '../../GoogleAPI/Authentication/Authentication.dart';
import 'package:provider/provider.dart';
import '../Subject/Theme.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';


//Creates an app with the theme
class ThemedApp extends StatelessWidget {
  @override
  Future<bool>_loginState;
  Auth _auth = Auth();
  Widget login;
  Future<bool> loginState() async{
    login = await _auth.isLoggedIn();
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