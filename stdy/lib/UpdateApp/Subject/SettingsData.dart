import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


int fontScale = 0;

//Class for handling the changing of the theme
class ThemeChanger with ChangeNotifier {

//saves theme to device
  Future<bool> saveTheme(String themeName) async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();

    return _prefs.setString('Theme', themeName);
  }

//loads theme through device
  static Future<String> loadTheme() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.getString('Theme') ?? "Light";
  }

  ThemeData _themeData;

  ThemeChanger(this._themeData);
  getTheme() => _themeData;//return theme

//set theme
  setTheme(ThemeData theme,String themeName) {
    _themeData = theme;
    notifyListeners();
    saveTheme(themeName);
  }
}

//Class that saves font size to shared preferences
class SaveFontScale{

  Future<bool> saveSize(int selectedSize) async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();

    return _prefs.setInt('Size', selectedSize);
  }

  Future<int> loadScale() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    fontScale = _prefs.getInt('Size') ?? 0;
    return fontScale;
  }

}

//Different themes defined
enum ThemeStyle {
  Light,
  Dark,
  DarkOLED,
}
final Color _stdyPink = Color(0xFFFDA3A4);
final themeStyleData = {
  ThemeStyle.Light: ThemeData(
    brightness: Brightness.light,
    primaryColor: _stdyPink,
    accentColor: _stdyPink,
    buttonColor: _stdyPink,
    primaryTextTheme: TextTheme(title: TextStyle(color: _stdyPink)),
  ),
  ThemeStyle.Dark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: _stdyPink,
    accentColor: _stdyPink,
    buttonColor: _stdyPink,
    primaryTextTheme: TextTheme(title: TextStyle(color: _stdyPink)),
  ),
  ThemeStyle.DarkOLED: ThemeData(
      brightness: Brightness.dark,
      primaryColor: _stdyPink,
      accentColor: _stdyPink,
      buttonColor: _stdyPink,
      primaryTextTheme: TextTheme(title: TextStyle(color: _stdyPink)),
      scaffoldBackgroundColor: Colors.black),
};
