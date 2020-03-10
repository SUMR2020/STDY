import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Settings/theme.dart';
import 'MaterialAppWithTheme.dart';

Future<bool> _themeLoaded;
String themeDrop;

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