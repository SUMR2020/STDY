import 'package:flutter/material.dart';
import 'home_widget.dart';
import 'login_page.dart';
import 'package:provider/provider.dart';
import 'bloc/theme.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'push_notifictions.dart' as notifs ;

Color stdyPink = Color(0xFFFDA3A4);
Future<bool> _themeLoaded;
String themeDrop;
int fontScale = 0;

Future<String> loadTheme() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('Theme') ?? "Light";
}





void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
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
    String theme = await loadTheme();
    return theme;
  }

  MyApp(){
    _themeLoaded = gotTheme();

  }

  Future<bool> gotTheme() async{
    theme = await loadTheme();
    return true;
  }
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(loadedTheme),
      child: FutureBuilder(
        future: _themeLoaded,
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if (snapshot.hasData){
          if(theme == "Light")loadedTheme = themeStyleData[ThemeStyle.Light];
          else if(theme == "Dark")loadedTheme = themeStyleData[ThemeStyle.Dark];
          else loadedTheme = themeStyleData[ThemeStyle.DarkOLED];
          themeDrop = theme;
          return new MaterialAppWithTheme();
          }
          else
            return CircularProgressIndicator();
        }
      )
      //new MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      theme: theme.getTheme(),
      title: 'STDY',
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => LoginScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) => Home(),
      },
    );
  }
}
