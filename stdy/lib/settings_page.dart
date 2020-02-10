import 'package:study/bloc/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            FlatButton(
                child: Text('Light Mode'),
                onPressed: () => _themeChanger.setTheme(themeStyleData[ThemeStyle.Light], "Light")),
            FlatButton(
                child: Text('Dark Mode'),
                onPressed: () => _themeChanger.setTheme(themeStyleData[ThemeStyle.Dark], "Dark")),
            FlatButton(
                child: Text('Dark Mode (OLED)'),
                onPressed: () => _themeChanger.setTheme(themeStyleData[ThemeStyle.DarkOLED], "OLED")),
          ],
        ),
      ),
    );
  }
}


