import 'package:flutter/material.dart';
import 'home_widget.dart';
import 'login_page.dart';


void main() => runApp(MyApp());
Color stdyPink = Color(0xFFFDA3A4);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: stdyPink,
        accentColor: stdyPink,
        buttonColor: stdyPink
      ),
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
