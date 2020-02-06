import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import '../home_widget.dart';

class GradesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GradesPageState();
  }
}

class GradesPageState extends State<GradesPage> {


  var _grade = <TextEditingController>[];
  var _weight = <TextEditingController>[];
  var _total = <TextEditingController>[];
  int marks;
  String _finalGradeText;

  //String get grade => _grade.text;
  static List<Widget> _children;

  GradesPageState(){
    print("regened state");
    _finalGradeText = '';
    marks = 0;

    _children = [];
  }

  void _calculateGrades(){

    double finalGrade = 0.0;

    for(int i =0; i<marks; i++){

      if(_grade[i].text=='' || _weight[i].text=='' || _total[i].text=='')
        return;

      double currGrade = double.parse(_grade[i].text);
      double currTotal = double.parse(_total[i].text);
      double currWeight = double.parse(_weight[i].text);
      double percentEarned = (currGrade/currTotal)*currWeight;
      finalGrade+=percentEarned;
      print("$i: grade= $currGrade, weight: $currWeight, total: $currTotal for a total of $percentEarned");


    }
    //round to 2 decimals
 
    setState((){
      _finalGradeText = finalGrade.toStringAsFixed(2);
    });


  }
  void _onAddGrade(){
    _grade.add(new TextEditingController());
    _weight.add(new TextEditingController());
    _total.add(new TextEditingController());

    setState(() {
      _children.add(
         Container(
          child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new SizedBox(width : 50,child: TextField(controller: _grade[marks],
                  decoration: new InputDecoration(hintText: "marks"),
                  keyboardType: TextInputType.number,)),
                new Text("out of"),
                new SizedBox(width : 50,child: TextField(controller: _total[marks],
                  decoration: new InputDecoration(hintText: "total"),
                  keyboardType: TextInputType.number,)),
                new Text("worth"),
                new SizedBox(width : 50,child: TextField(controller: _weight[marks],
                  decoration: new InputDecoration(hintText: "%"),
                  keyboardType: TextInputType.number,)),
              ]
          )
        )
        ,
      );
    });

    marks++;
  }


  @override
  Widget build(BuildContext context) {
    print('in build$_finalGradeText');
    return Scaffold(
      body: SingleChildScrollView(

        child: Column(
          children: <Widget>[

            RaisedButton(
              child: Text('Add new Grade'),
              onPressed: (){
                _onAddGrade();
              },
            ),
            RaisedButton(
              child: Text('Calculate Grade'),
              onPressed: () {
                _calculateGrades();
              },
            ),
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text('Grade: $_finalGradeText'),
                    ]
                )
            ),
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text('Grade'),
                      Text('Weight'),
                      Text('Total')
                    ]
                )
            ),
            Container(
              child: Column(
                children: _children,
              )
            )


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

