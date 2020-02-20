import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';

class TaskInputPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskInputState();
  }
}

class TaskInputState extends State<TaskInputPage>{

  List<String> tasks = ["Choose Task", "ASSIGNMENT", "TUTORIAL", "PARTICIPATION","PROJECT", "EXAM"];
  var _weight = TextEditingController();
  var _total = TextEditingController();
  var _grade = TextEditingController();
  var _name = TextEditingController();

  String dropdownValueTask;

  TaskInputPage(){
    dropdownValueTask = "Choose Task";
  }

  void addCourseButton(BuildContext context){

    if(dropdownValueTask=="Semester" ||
        _weight.text=='' || _total.text=='' || _grade.text=='' || _name.text==''
    ){
      _showDialog();
      return;
    }


    print(dropdownValueTask);
    Navigator.pop(context, [dropdownValueTask.toLowerCase(),  _name.text, _weight.text,_total.text, _grade.text]);
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
          title: Text('INPUT TASK')
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Task name"),
              new SizedBox( child: TextField(controller: _name,
                decoration: new InputDecoration(),
              )),
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
              Text("Task type"),
              DropdownButton<String>(
                value: dropdownValueTask,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                    color: stdyPink
                ),
                underline: Container(
                  height: 2,
                  color: stdyPink,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValueTask = newValue;
                  });
                },
                items: tasks
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                })
                    .toList(),
              ),

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
