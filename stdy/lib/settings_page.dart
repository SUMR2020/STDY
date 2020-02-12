import 'package:study/bloc/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/login_page.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _signOut() async {
    await _firebaseAuth.signOut();
    signOutGoogle();
  }
  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Text("Select Theme"),
            DropdownButton<String>(
              isExpanded: true,
              value: themeDrop,
              icon: Icon(Icons.arrow_drop_down),
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
//            RaisedButton(
//              child: Text('Font Up'),
//              onPressed: (){
//                fontScale = fontScale+2;
//                print(fontScale);
//              },
//            ),
//            RaisedButton(
//              child: Text('Font Down'),
//              onPressed: (){
//                fontScale = fontScale-2;
//                print(fontScale);
//              },
//            ),
            Slider(
                value: fontScale.toDouble(),
                min: -10.0,
                max: 19.0,
                divisions: 10,
                activeColor: stdyPink,
                inactiveColor: Colors.blueGrey,
                label: fontScale.toString(),
                onChanged: (double newValue) {
                  setState(() {
                    fontScale = newValue.round();
                  });
                },
                semanticFormatterCallback: (double newValue) {
                  return '${newValue.round()} dollars';
                }
            ),
            RaisedButton(
              child: Text('Sign Out'),
              onPressed: (){
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
          ],
        ),
      ),
    );
  }
}
