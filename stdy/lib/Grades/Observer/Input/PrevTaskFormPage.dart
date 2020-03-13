import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../UpdateApp/Subject/Theme.dart';

class TaskInputPage extends StatefulWidget {

  double totalWeight;
  TaskInputPage(this.totalWeight);
  @override
  State<StatefulWidget> createState() {
    return TaskInputState(totalWeight);
  }
}

class TaskInputState extends State<TaskInputPage>{

  List<String> tasks = ["ASSIGNMENT", "TUTORIAL", "PARTICIPATION","PROJECT", "EXAM"];

  String _weight;
  String _total;
  String _grade;
  String _name;
  bool _bonus = false;
  double totalWeight;

  String dropdownValueTask;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TaskInputState(double tW){
    totalWeight = tW;
  }

  void addCourseButton(BuildContext context) {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (dropdownValueTask == null) {
        _showDialog();
        return;
      }

      print(dropdownValueTask);
      Navigator.pop(context, [dropdownValueTask.toLowerCase(),_name,_weight,_total,_grade, _bonus.toString()]);
    }
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

  String _validateTaskName(String value) {
    if (value.isEmpty) return 'Please enter a valid task name.';
    return null;
  }

  String _validateTaskGrade(String value) {
    if (value.isEmpty) return 'Please enter a valid task grade.';
    return null;
  }

  String _validateTaskTotal(String value) {
    if (value.isEmpty) return 'Please enter a valid task total.';
    return null;
  }

  String _validateTaskWeight(String value) {

    double val = double.parse(value);
    print("value of bonus is $_bonus and  double is $val and total is $totalWeight");
    if(val+totalWeight>100 && !_bonus) return 'Total course weight exceeds 100. Enter weight less than ${100-totalWeight}\n or select bonus';
    if (value.isEmpty) return 'Please enter a valid task weight.';
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColor, //change your color here
          ),
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text('INPUT TASK')
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            key: this._formKey,
            child: new ListView(

            children: <Widget>[
              new TextFormField(
                  style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  ),
                  decoration: new InputDecoration(
                    hintText: 'Enter task name here...',
                    labelText: "Task name *",
                  ),
                  validator: this._validateTaskName,
                  onSaved: (String value) {
                    print("val is $value");
                    _name = value;
                  }),
              new TextFormField(
                  style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    hintText: 'Enter task grade here...',
                    labelText: "Task grade *",
                  ),
                  validator: this._validateTaskGrade,
                  onSaved: (String value) {
                    print("val is $value");
                    _grade = value;
                  }),
              new TextFormField(
                  style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    hintText: 'Enter task total marks here...',
                    labelText: "Task total marks *",
                  ),
                  validator: this._validateTaskTotal,
                  onSaved: (String value) {
                    print("val is $value");
                    _total = value;
                  }),
              new TextFormField(
                  style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    hintText: 'Enter task weight here...',
                    labelText: "Task weight *",
                  ),
                  validator: this._validateTaskWeight,
                  onSaved: (String value) {
                    print("val is $value");
                    _weight = value;
                  }),
              Text("Task type"),
              DropdownButton<String>(

                hint: Text("Choose task type"),
                value: dropdownValueTask,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16.0+ fontScale,
                ),
                underline: Container(
                  height: 2,
                  color: Theme.of(context).primaryColor,
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
              new CheckboxListTile(

                title: Text("Is this a bonus task?",
                  style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  ),),
                value: _bonus,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (bool value) {
                  setState(() {
                    _bonus = value;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              RaisedButton(
                child: Text('Add task',
                  style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  ),),
                onPressed: (){
                  addCourseButton(context);
                },
              ),

            ],
          ),
          )

      ),
    );
  }


}
