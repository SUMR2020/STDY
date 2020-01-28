import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'home_widget.dart';

class GradesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GradesPageState();
  }
}

class GradesPageState extends State<GradesPage> {

  static final TextEditingController _grade = new TextEditingController();

  GradesPageState(){
    _children = [
      RaisedButton(
        child: Text('Add new Grade'),
        onPressed: (){
          _onAddGrade();
        },
      ),
      RaisedButton(
        child: Text('Calculate Grade'),
        onPressed: () {
        },
      ),

      new TextField(controller: _grade,
        decoration: new InputDecoration(hintText: "0-100%"),),

    ];
  }

  String get grade => _grade.text;
  static List<Widget> _children;


  void _onAddGrade(){
    setState(() {
      _children.add(
          new TextField(controller: _grade,
            decoration: new InputDecoration(hintText: "0-100%"))
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(

        child: Column(
          children: _children
        ),

      ),
    );
  }
}

