import 'package:flutter/material.dart';
import 'package:study/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class ThemeChanger with ChangeNotifier {

  Future<bool> saveTheme(String themeName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString('Theme', themeName);
  }

  static Future<String> loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('Theme') ?? "Light";
  }

  ThemeData _themeData;

  ThemeChanger(this._themeData);
  getTheme() => _themeData;

  setTheme(ThemeData theme,String themeName) {
    _themeData = theme;
    notifyListeners();
    saveTheme(themeName);
  }
}

class SaveFontScale{

  Future<bool> saveSize(int selectedSize) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt('Size', selectedSize);
  }

  Future<int> loadScale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    fontScale = prefs.getInt('Size') ?? 0;
    print("FONTSCALE "+fontScale.toString());
    return fontScale;
  }

}

enum ThemeStyle {
  Light,
  Dark,
  DarkOLED,
}

final themeStyleData = {
  ThemeStyle.Light: ThemeData(
    brightness: Brightness.light,
    primaryColor: stdyPink,
    accentColor: stdyPink,
    buttonColor: stdyPink,
    primaryTextTheme: TextTheme(title: TextStyle(color: stdyPink)),
  ),
  ThemeStyle.Dark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: stdyPink,
    accentColor: stdyPink,
    buttonColor: stdyPink,
    primaryTextTheme: TextTheme(title: TextStyle(color: stdyPink)),
  ),
  ThemeStyle.DarkOLED: ThemeData(
      brightness: Brightness.dark,
      primaryColor: stdyPink,
      accentColor: stdyPink,
      buttonColor: stdyPink,
      primaryTextTheme: TextTheme(title: TextStyle(color: stdyPink)),
      scaffoldBackgroundColor: Colors.black),
};
