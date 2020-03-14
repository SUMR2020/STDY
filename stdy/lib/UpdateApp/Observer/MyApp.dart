import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Subject/SettingsData.dart';
import '../UI/ThemedApp.dart';

String themeDrop;

//creates a themed app
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  ThemeData loadedTheme;
  String theme;
  Future<bool> _themeLoaded;

  Future<String> getSavedTheme() async {
    String theme = await ThemeChanger.loadTheme();
    return theme;
  }

  MyApp() {
    _themeLoaded = gotTheme();
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
                return new ThemedApp();
              } else
                return CircularProgressIndicator();
            })
        //new MaterialAppWithTheme(),
        );
  }
}