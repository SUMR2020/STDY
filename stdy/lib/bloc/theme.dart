import 'package:flutter/material.dart';
import 'package:study/main.dart';

class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;

  ThemeChanger(this._themeData);
  getTheme() => _themeData;

  setTheme(ThemeData theme) {
    _themeData = theme;

    notifyListeners();
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
  ),
  ThemeStyle.Dark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: stdyPink,
    accentColor: stdyPink,
    buttonColor: stdyPink,
  ),
  ThemeStyle.DarkOLED: ThemeData(
    brightness: Brightness.dark,
    primaryColor: stdyPink,
    accentColor: stdyPink,
    buttonColor: stdyPink,
    scaffoldBackgroundColor: Colors.black
  ),
};
