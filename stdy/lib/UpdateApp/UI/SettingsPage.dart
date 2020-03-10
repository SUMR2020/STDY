import 'package:study/UpdateApp/Subject/Theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/UpdateApp/UI/LoginPage.dart';
import '../../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../GoogleAPI/Authentication/Authentication.dart';
import 'package:study/UpdateApp/Observer/MyApp.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _signOut() async {
    await _firebaseAuth.signOut();
    Authentication().signOutGoogle();
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Text(
                  "Select Theme",
                  style: TextStyle(fontSize: 14.0 + fontScale),
                ),
              ),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: themeDrop,
              icon: Icon(Icons.settings_brightness),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: stdyPink),
              underline: Container(
                height: 2,
                color: stdyPink,
              ),
              onChanged: (String newValue) {
                setState(() {
                  themeDrop = newValue;
                  if (themeDrop == "Light")
                    _themeChanger.setTheme(
                        themeStyleData[ThemeStyle.Light], "Light");
                  else if (themeDrop == "Dark")
                    _themeChanger.setTheme(
                        themeStyleData[ThemeStyle.Dark], "Dark");
                  else
                    _themeChanger.setTheme(
                        themeStyleData[ThemeStyle.DarkOLED], "Dark(OLED)");
                });
              },
              items: <String>["Light", "Dark", "Dark(OLED)"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Text(
              'Change Font Size',
              style: TextStyle(
                fontSize: 14.0 + fontScale
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              Text(
                'A',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
              Container(
                width: 350,
              child:Slider(
                  value: fontScale.toDouble(),

                  min: -5.0,
                  max: 20.0,
                  divisions: 25,
                  activeColor: stdyPink,
                  inactiveColor: Colors.blueGrey,
                  label: ((fontScale / 20) * 100).toInt().toString() + "%",
                  onChanged: (double newValue) {
                    setState(() {
                      fontScale = newValue.round();
                      SaveFontScale().saveSize(fontScale);
                    });
                  },
                  semanticFormatterCallback: (double newValue) {
                    return '${newValue.round()} dollars';
                  }),
              ),
              Text(
                'A',
                style: TextStyle(
                  fontSize: 34,
                ),
              ),
            ]),
            new Container(
              height: 480,
            ),
            new Align(
                alignment: Alignment.bottomCenter,
              child:
            RaisedButton(
              child: Text('Sign Out'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      _signOut();
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
    ),
          ],
        ),
      ),
    );
  }
}
