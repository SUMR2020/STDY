import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';
import 'package:flutter/services.dart';
import '../Schedule/TaskData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/Grades/Model/CourseData.dart';

//https://stackoverflow.com/questions/57300552/flutter-row-inside-listview

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
  String dropdownValueGrade;
  String dropdownValueLetter;
  bool _curr;
  CourseData firestore;
  List<String> semesters;


  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  CourseInputState(){
    _curr = false;
    dropdownValueGrade = "Letter";
    firestore = CourseData();
    semesters = <String>["Fall", "Winter", "Summer"];

    print(semesters);

  }

  void addCourseButton(BuildContext context) async{

    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();

      if(_curr){
        var now = new DateTime.now();
        _addYear = now.year.toString();

        int month = now.month;
        if(month>=1 && month <5)dropdownValueSem = semesters[1];
        if(month>=5 && month <9)dropdownValueSem = semesters[2];
        if(month>=9)dropdownValueSem = semesters[0];
        _addGrade="CURR";

      }
      else{
        if(dropdownValueGrade=="Letter" && !_curr) {
          if(dropdownValueLetter==null){
            _showDialog("Choose a letter grade");
            return;
          }
          _addGrade = await firestore.convertLetterToDouble(dropdownValueLetter);
        }
        print("grade chosen is $_addGrade");


        if (dropdownValueSem == null) {
          _showDialog("Select a semester");
          return;
        }


      }



      print("adding $_addCourse $_addYear $dropdownValueSem, $_addGrade");
      Navigator.pop(context, [_addCourse, dropdownValueSem, _addYear, _addGrade]);

    }
}

  void _showDialog(String text) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text(text),
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

    if (value.isEmpty ) return 'Please enter a valid course name.';

    return null;
  }

  String _validateCourseYear(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.

    var now = new DateTime.now();
    int year = now.year;

    if (value.isEmpty && !_curr || (int.parse(value)>year) ) return 'Please enter a valid course year.';

    return null;
  }

  String _validateCourseGrade(String value) {
    if (value.isEmpty && !_curr) return 'Please enter a valid grade.';
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    //if (value.isEmpty) return 'Please enter a valid course grade.';
    return null;
  }
  Widget _buildGradeForm(BuildContext context){

    if(dropdownValueGrade=="Letter"){
      return Container(
        child: DropdownButton<String>(

        hint: Text("Letter grade"),
        value: dropdownValueLetter,
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(
            color: Theme.of(context).primaryColor,
          fontSize: 16.0+fontScale,
        ),
        underline: Container(
          height: 2,
          color: Theme.of(context).primaryColor,

        ),
        onChanged: (String newValue) {
          setState(() {
            dropdownValueLetter = newValue;
          });
        },
        items: firestore.grades.reversed
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        })
            .toList(),
        )
      );
    }
    else{
      return new Flexible(
          child: new TextFormField(
              keyboardType: (dropdownValueGrade=="Percentage")? TextInputType.number: TextInputType.text,
              decoration: new InputDecoration(
                hintText: 'Enter course grade here...',
                labelText: !_curr? "Course grade": "" ,
              ),
              validator: this._validateCourseGrade,
              onSaved: (String value) {
                print("val is $value");
                _addGrade = value;
              }) );
    }
  }

  Widget _buildForm(BuildContext context){
    return new Form(
        key: this._formKey,
        child: new Column(

          children: <Widget>[


            new CheckboxListTile(

              title: Text("Is this a current course?",
                style: TextStyle(
                  fontSize: 16.0 + fontScale,
                ),),
              value: _curr,
              onChanged: (bool value) {
                setState(() {
                  _addGrade = null;
                  dropdownValueLetter = null;
                  _curr = value;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),


            new TextFormField(
                style: TextStyle(
                  fontSize: 16.0 + fontScale,
                ),
                decoration: new InputDecoration(
                  hintText: 'Enter course name here...',
                  labelText: "Course name *",
                ),
                validator: this._validateCourseName,
                onSaved: (String value) {
                  print("val is $value");
                  _addCourse = value;
                }),

            new Visibility(
              visible: !_curr,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[


                  new TextFormField(
                      style: TextStyle(
                        fontSize: 16.0 + fontScale,
                      ),
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
                  DropdownButton<String>(

                    isExpanded: true,
                    hint: Text("Semester"),
                    value: dropdownValueSem,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(
                        fontSize: 16.0 + fontScale,
                        color: Theme.of(context).primaryColor
                    ),
                    underline: Container(
                      height: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValueSem = newValue;
                      });
                    },
                    items: semesters.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                        .toList(),
                  ),

                  Row(
                      children: <Widget>[
                        DropdownButton<String>(
                          value: dropdownValueGrade,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16.0+fontScale,
                          ),
                          underline: Container(
                            height: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                          onChanged: !_curr ? (String newValue) => setState(() => dropdownValueGrade = newValue) : null,
                          /*_curr? (String newValue) {


                      setState(() {
                        dropdownValueGrade = newValue;
                      });
                    }: null,*/
                          items: <String>["Letter", "Percentage"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          })
                              .toList(),
                        ),
                        SizedBox(width: 10),
                        _buildGradeForm(context),



                      ]
                  ),


                ]
              )



            ),



            RaisedButton(
              child: Text('Add course',
                  style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  )
              ),

              onPressed: (){
                addCourseButton(context);
              },
            ),


          ],
        )
    );
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
      body:

      new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Column(
            children: <Widget>[
              _buildForm(context),

            ],
          )
          //,



      ),
    );
  }
}

/*

 */