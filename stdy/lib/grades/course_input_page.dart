import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';
import 'package:flutter/services.dart';

class CourseInputPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CourseInputState();
  }
}

class CourseInputState extends State<CourseInputPage>{


  String _addCourse;
  String _addYear;
  String _addGrade;

  String dropdownValueSem;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  CourseInputState(){
    dropdownValueSem = "Semester";

  }

  void addCourseButton(BuildContext context){

    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();


      if (dropdownValueSem == "Semester") {
        _showDialog();
        return;
      }
      if(_addGrade=='')
        _addGrade="CURR";

      print("adding $_addCourse $_addYear $dropdownValueSem, $_addGrade");
      Navigator.pop(context, [_addCourse, dropdownValueSem, _addYear, _addGrade]);
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
          content: new Text("Select a semester"),
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

  String _validateCourseName(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    if (value.isEmpty) return 'Please enter a valid course name.';
    return null;
  }

  String _validateCourseYear(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    if (value.isEmpty) return 'Please enter a valid course year.';
    return null;
  }

  String _validateCourseGrade(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    //if (value.isEmpty) return 'Please enter a valid course grade.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text('INPUT COURSE')
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),

          child: new Form(
            key: this._formKey,
            child: new ListView(

            children: <Widget>[
              new TextFormField(
                  decoration: new InputDecoration(
                    hintText: 'Enter course name here...',
                    labelText: "Course name *",
                  ),
                  validator: this._validateCourseName,
                  onSaved: (String value) {
                    print("val is $value");
                    _addCourse = value;
                  }),

              new TextFormField(
                keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    hintText: 'Enter course year here...',
                    labelText: "Course year *",
                  ),
                  validator: this._validateCourseYear,
                  onSaved: (String value) {
                    print("val is $value");
                    _addYear = value;
                  }),
              new TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    hintText: 'Enter course grade here...',
                    labelText: "Course grade (Leave blank for Current)",
                  ),
                  validator: this._validateCourseGrade,
                  onSaved: (String value) {
                    print("val is $value");
                    _addGrade = value;
                  }),

              Text("Course Semester"),
              DropdownButton<String>(
                value: dropdownValueSem,
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
                    dropdownValueSem = newValue;
                  });
                },
                items: <String>["Semester","Fall", "Winter", "Summer"]
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
          )

      ),
    );
  }
}
