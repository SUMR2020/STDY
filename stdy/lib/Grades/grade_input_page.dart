import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';

class GradeInputPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GradeInputState();
  }
}

class GradeInputState extends State<GradeInputPage>{

  var _weight = TextEditingController();
  var _total = TextEditingController();
  var _grade = TextEditingController();


  TaskInputPage(){

  }

  void addCourseButton(BuildContext context){

    if(_weight.text=='' || _total.text=='' || _grade.text==''
    ){
      _showDialog();
      return;
    }

    Navigator.pop(context, [_weight.text,_total.text, _grade.text]);
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text("One of the input fields is empty."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text('INPUT GRADE')
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Task grade"),
              new SizedBox(child: TextField(controller: _grade,
                  decoration: new InputDecoration(),keyboardType: TextInputType.number
              )),
              Text("Task total marks"),
              new SizedBox(child: TextField(controller: _total,
                  decoration: new InputDecoration(),keyboardType: TextInputType.number
              )),
              Text("Task total weight"),
              new SizedBox(child: TextField(controller: _weight,
                  decoration: new InputDecoration(),keyboardType: TextInputType.number
              )),


              RaisedButton(
                child: Text('Add course'),
                onPressed: (){
                  addCourseButton(context);
                },
              ),

            ],
          )

      ),
    );
  }


}
