import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'grades_data.dart';

class GradesYearPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GradesYearPageState();
  }
}

class GradesYearPageState extends State<GradesYearPage> {

  GradeData data;

  int marks;
  String _finalGradeText;

  //String get grade => _grade.text;
  static List<Widget> _children;

  GradesYearPageState(){
    data = new GradeData();

    _finalGradeText = '';
    marks = 0;

    _children = [];
  }

void _addData() {
    data.addData();
}

void _getData(){
    data.getCourses();
}

  @override
  Widget build(BuildContext context) {
    print('in build$_finalGradeText');
    return Scaffold(
      body: SingleChildScrollView(

        child: Column(
          children: <Widget>[

            RaisedButton(
              child: Text('Add new collection'),
              onPressed: (){
                _addData();
              },
            ),
            RaisedButton(
              child: Text('Get collection'),
              onPressed: (){
                _getData();
              },
            ),

            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text('Years'),
                    ]
                )
            ),

            /*new TextField(controller: _grade,
        decoration: new InputDecoration(hintText: "0-100%"),
        keyboardType: TextInputType.number,),
    */
          ],

        ),

      ),
    );
  }
}



