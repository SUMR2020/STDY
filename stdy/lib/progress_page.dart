import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'home_widget.dart';

class progressPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return progressPageState();
  }
}

class progressPageState extends State<progressPage>{

  static final TextEditingController _task = new TextEditingController();
  static List<Widget> _children;

  progressPageState(){}


  Widget build(BuildContext context) {
    return Scaffold(
      //just testing
      body: Center(
        child: RaisedButton(
          child: Text("Enter new task"),
          onPressed: () {},
        ),
      ),
    );
  }
}

