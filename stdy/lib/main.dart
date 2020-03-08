import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:provider/provider.dart';
import 'bloc/theme.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'push_notifictions.dart' as notifs;

Color stdyPink = Color(0xFFFDA3A4);
Future<bool> _themeLoaded;
String themeDrop;
int fontScale = 0;
String name = "";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);//Removes the navigation bar
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])//Locks app to portrait mode
      .then((_) {
    notifs.PushNotificationsManager().init();
    SaveFontScale().loadScale();
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  ThemeData loadedTheme;
  String theme;


  Future<String> getSavedTheme() async {
    String theme = await ThemeChanger.loadTheme();
    return theme;
  }

  MyApp() {
    _themeLoaded = gotTheme();
   // _authorized = _auth.isLoggedIn();
  }

  Future<bool> gotTheme() async {
    theme = await ThemeChanger.loadTheme();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
        create: (_) => ThemeChanger(loadedTheme),
        child: FutureBuilder(
            future: _themeLoaded,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (theme == "Light")
                  loadedTheme = themeStyleData[ThemeStyle.Light];
                else if (theme == "Dark")
                  loadedTheme = themeStyleData[ThemeStyle.Dark];
                else
                  loadedTheme = themeStyleData[ThemeStyle.DarkOLED];
                themeDrop = theme;
                return new MaterialAppWithTheme();
              } else
                return CircularProgressIndicator();
            })
        //new MaterialAppWithTheme(),
        );
  }
}

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
