import 'package:flutter/material.dart';
import 'package:study/main.dart';
import 'package:study/progress_page.dart';
import 'grades/grades_year_page.dart';
import 'schedule_page.dart';
import 'settings_page.dart';
import 'dart:async';

import "package:http/http.dart" as http;
import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart' as login;

final GoogleSignIn _googleSignIn =
new GoogleSignIn(scopes: [calendar.CalendarApi.CalendarScope]);

final scopes = [calendar.CalendarApi.CalendarScope];

Future<calendar.CalendarApi> gettingCalendar() async {
  calendar.CalendarApi calendarApi;
  calendarApi = new calendar.CalendarApi(login.authClient);
  return calendarApi;
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    SchedulePage(),
    progressPage(),
    GradesYearPage(),
    SettingsScreen()
  ];

  @override
  void initState() {
    super.initState();
    //_testSignInWithGoogle();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0x00000000),
        elevation: 0,
        title: Text('STDY'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: stdyPink,
        unselectedItemColor: stdyPink,
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text('Schedule'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            title: Text('Progress'),
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.add),
              title: Text('Grade Calculator')
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text('Settings')
          )
        ],
      ),
    );

  }
  void onTabTapped(int index) {
    setState(() {

      _currentIndex = index;
    });
  }
}

