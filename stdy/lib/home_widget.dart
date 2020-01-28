import 'package:flutter/material.dart';
import 'package:study/progress_page.dart';
import 'placeholder_widget.dart';
import 'grades_page.dart';
import 'schedule_page.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  int _currentIndex = 0;
  final List<Widget> _children = [
    SchedulePage(),
    progressPage(), // put progress widget here (minna)
    GradesPage() // put grademain widget here(sharjeel)
  ];
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