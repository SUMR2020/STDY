import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:googleapis/cloudbuild/v1.dart';
import '../main.dart';
import 'package:intl/intl.dart';

class TaskInfoPage extends StatefulWidget {
  Map<String, dynamic> task;
  TaskInfoPage(this.task);

  @override
  State<StatefulWidget> createState() {
    return TaskInfoState(task);
  }
}

class TaskInfoState extends State<TaskInfoPage> {
  Map<String, dynamic> task;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TaskInfoState(Map<String, dynamic> t){
    task = t;

  }

  String _validateCourseName(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    if (value.isEmpty) return 'Please enter a valid course name.';
    return null;
  }

  String formatTimestamp(int timestamp) {
    var format = new DateFormat('d MMM, hh:mm a');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return format.format(date);
  }

  List<Widget> taskInfo(BuildContext context){
    String dueDate="Past";
    double hours=0;
    double weight=0;
    double grade=0;
    double total=0;
    
    String earned='N/A';
    String weighted='N/A';
    double percent;
    bool bonus = false;

    if(task.containsKey("bonus")){
      bonus = task["bonus"];
    }

    String temp;

    if(task["grade"]!=null){
      weight = task["weight"];
      grade = task["grade"];
      total = task["total"];

      percent = grade / total;
      double gradeWeighted =  percent* weight;
      gradeWeighted = double.parse(gradeWeighted.toStringAsFixed(1));
      percent = double.parse((percent*100).toStringAsFixed(1));

      earned = "$grade/$total";
      weighted = "$gradeWeighted/$weight";

    }
    
    if(task.containsKey("due")){
      print("timestamp is ${task["due"]}");
      dueDate = formatTimestamp(task["due"].seconds);
      hours = task["toDo"];
    }

    List<Widget> tasks = <Widget>[
      new TextFormField(
          decoration: new InputDecoration(
            labelText: "Task name",
          ),
          initialValue: task["name"],
          validator: this._validateCourseName,
          onSaved: (String value) {
            temp = value;
          }),
      new TextFormField(//remove decimal if its 0. 
          decoration: new InputDecoration(
            labelText: "Task grade",
          ),
          initialValue: grade.toString(),
          validator: this._validateCourseName,
          onSaved: (String value) {
            temp = value;
          }),
      new TextFormField(
          decoration: new InputDecoration(
            labelText: "Task total marks",
          ),
          initialValue: total.toString(),
          validator: this._validateCourseName,
          onSaved: (String value) {
            temp = value;
          }),
      new TextFormField(
          decoration: new InputDecoration(
            labelText: "Task weight",
          ),
          initialValue: weight.toString(),
          validator: this._validateCourseName,
          onSaved: (String value) {
            temp = value;
          }),
      new TextFormField(
          decoration: new InputDecoration(
            labelText: "Task hours left",
          ),
          initialValue: hours.toString(),
          validator: this._validateCourseName,
          onSaved: (String value) {
            temp = value;
          }),

      Text("Earned: $earned"),
      Text("Weighted: $weighted"),
      Text("Percent: $percent"),
      Text("Type: ${task["type"]}"),
      Text("Due date: $dueDate"),
      new CheckboxListTile(
        title: Text("Bonus task"),
        value: bonus,
        onChanged: (bool value) {
          setState(() {
            bonus = value;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      )
    ];


    return tasks;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text('Task Info')
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),

          child: new Form(
              key: this._formKey,
              child: new ListView(

                children: taskInfo(context)

              )
          )

      ),
    );
  }


}