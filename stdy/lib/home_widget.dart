import 'package:flutter/material.dart';
import 'package:study/progress_page.dart';
import 'grades_year_page.dart';
import 'schedule_page.dart';
import 'dart:async';

import "package:http/http.dart" as http;
import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';


final GoogleSignIn _googleSignIn =
new GoogleSignIn(scopes: [calendar.CalendarApi.CalendarScope]);

final scopes = [calendar.CalendarApi.CalendarScope];


class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

calendar.CalendarApi calendarApi;

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    SchedulePage(),
    progressPage(), // put progress widget here (minna)
    GradesYearPage() // put grademain widget here(sharjeel)
  ];
  //calendar.CalendarApi calendarApi;
  _testSignInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    auth.AccessToken token = auth.AccessToken("Bearer", googleAuth.accessToken,
        DateTime.now().add(Duration(days: 1)).toUtc());
    auth.AccessCredentials(token, googleUser.id, scopes);
    http.BaseClient _client = http.Client();
    auth.AuthClient _authClient = auth.authenticatedClient(
        _client, auth.AccessCredentials(token, googleUser.id, scopes));
    calendarApi = new calendar.CalendarApi(_authClient);
    var calEvents = calendarApi.events.list("primary");
    calEvents.then((_events) {
      _events.items.forEach((_event) {
        print(_event.summary);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _testSignInWithGoogle();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STDY'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
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

