import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'home_widget.dart';

class SchedulePage extends StatelessWidget {



  const SchedulePage ({
    Key key,
    @required this.onSubmit,
  }): super(key: key);


  final VoidCallback onSubmit;

  static final TextEditingController _grade = new TextEditingController();
  String get grade => _grade.text;

  @override
  Widget build(BuildContext context){
   // getEvents();
    return new Column(
      children: <Widget>[
        new TextField(controller: _grade, decoration: new InputDecoration(hintText: "Schedule"), ),
      ],
    );

  }
}
//
//void getEvents() {
//  var calEvents = calendarApi.events.list("primary");
//  calEvents.then((_events) {
//    _events.items.forEach((_event) {
//      print(_event.summary);
//    });
//  });
//}
