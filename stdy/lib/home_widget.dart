import 'package:flutter/material.dart';
import 'package:study/main.dart';
import 'package:study/progress_page.dart';
import 'grades/grades_year_page.dart';
import 'Schedule/schedule_page.dart';
import 'Settings/settings_page.dart';

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
    GradesYearPage(),
    progressPage(),
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
        backgroundColor: Color(0x00000000),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.all(8.0), child: Text('Welcome ' + name+"!")),
        Image.asset(
              'assets/appbar.png',
              fit: BoxFit.contain,
              height: 110,
            ),

          ],
        ),
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
              icon: Icon(Icons.school),
              title: Text('Courses')
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            title: Text('Progress'),
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

