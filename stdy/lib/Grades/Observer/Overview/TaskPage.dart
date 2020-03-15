import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../UpdateApp/Subject/Theme.dart';
import 'package:intl/intl.dart';
import '../../Subject/GradesData.dart';

class TaskPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return TaskState();
  }
}

class TaskState extends State<TaskPage> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  bool _bonus;
  GradesData gradesData;
  TaskState(){
    gradesData = new GradesData();
    _bonus = gradesData.getTaskByID(GradesData.currTaskID).bonus;

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
    int total=0;
    
    String earned='N/A';
    String weighted='N/A';
    double percent;

    String temp;

    if(gradesData.getTaskByID(GradesData.currTaskID).grade!=null){
      weight = gradesData.getTaskByID(GradesData.currTaskID).weight;
      grade = gradesData.getTaskByID(GradesData.currTaskID).grade;
      total = gradesData.getTaskByID(GradesData.currTaskID).totalGrade;

      percent = grade / total;
      double gradeWeighted =  percent* weight;
      gradeWeighted = double.parse(gradeWeighted.toStringAsFixed(1));
      percent = double.parse((percent*100).toStringAsFixed(1));

      earned = "$grade/$total";
      weighted = "$gradeWeighted/$weight";

    }
    /*
    if(gradesData.getTaskByID(GradesData.currTaskID)!=null){
      print("timestamp is ${task["due"]}");
      dueDate = formatTimestamp(task["due"].seconds);
      hours = double.parse(task["toDo"].toString());
    }*/

    List<Widget> tasks = <Widget>[
      new TextFormField(
          style: TextStyle(
            fontSize: 16.0 + fontScale,
          ),
          decoration: new InputDecoration(
            labelText: "Task name",
          ),
          initialValue: gradesData.getTaskByID(GradesData.currTaskID).name,
          validator: this._validateCourseName,
          onSaved: (String value) {
            temp = value;
          }),
      new TextFormField(//remove decimal if its 0.
          style: TextStyle(
            fontSize: 16.0 + fontScale,
          ),
          decoration: new InputDecoration(
            labelText: "Task grade",
          ),
          keyboardType: TextInputType.number,
          initialValue: grade.toString(),
          validator: this._validateCourseName,
          onSaved: (String value) {
            temp = value;
          }),
      new TextFormField(
          style: TextStyle(
            fontSize: 16.0 + fontScale,
          ),
          decoration: new InputDecoration(
            labelText: "Task total marks",
          ),
          keyboardType: TextInputType.number,
          initialValue: total.toString(),
          validator: this._validateCourseName,
          onSaved: (String value) {
            temp = value;
          }),
      new TextFormField(
          style: TextStyle(
            fontSize: 16.0 + fontScale,
          ),
          decoration: new InputDecoration(
            labelText: "Task weight",
          ),
          keyboardType: TextInputType.number,
          initialValue: weight.toString(),
          validator: this._validateCourseName,
          onSaved: (String value) {
            temp = value;
          }),
      new TextFormField(
          style: TextStyle(
            fontSize: 16.0 + fontScale,
          ),
          decoration: new InputDecoration(
            labelText: "Task hours left",
          ),
          keyboardType: TextInputType.number,
          initialValue: hours.toString(),
          validator: this._validateCourseName,
          onSaved: (String value) {
            temp = value;
          }),

      Text("Earned: $earned",
        style: TextStyle(
          fontSize: 16.0 + fontScale,
        ),),
      Text("Weighted: $weighted",
        style: TextStyle(
          fontSize: 16.0 + fontScale,
        ),),
      Text("Percent: $percent",
        style: TextStyle(
          fontSize: 16.0 + fontScale,
        ),),
      Text("Type: ${gradesData.getTaskByID(GradesData.currTaskID).type}",
        style: TextStyle(
          fontSize: 16.0 + fontScale,
        ),),
      Text("Due date: $dueDate",
        style: TextStyle(
          fontSize: 16.0 + fontScale,
        ),),

      new CheckboxListTile(
        title: Text("Bonus task",
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
      )
    ];


    return tasks;

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
          title: Text('TASK INFO')
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