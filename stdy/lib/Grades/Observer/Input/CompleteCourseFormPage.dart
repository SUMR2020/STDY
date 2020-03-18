import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:study/Grades/Helper/GPATable.dart';
import 'package:study/UpdateApp/Subject/SettingsData.dart';

import 'package:flutter/services.dart';
import 'package:study/GoogleAPI/Firestore/GradesFirestore.dart';
import '../../Subject/GradesData.dart';

//https://stackoverflow.com/questions/57300552/flutter-row-inside-listview

class CompleteCourseFormPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CompleteCourseFormState();
  }
}

class CompleteCourseFormState extends State<CompleteCourseFormPage>{


  String _addCourse;
  String _addGrade;
  String dropdownValueGrade;
  String dropdownValueLetter;
  bool _comp;
  GradesData gradesData;



  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  CompleteCourseFormState(){
    _comp = false;
    dropdownValueGrade = "Letter";
    gradesData = GradesData();

  }

  void completeCourse(BuildContext context) async{

    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();

      if(_comp){
        _addGrade = gradesData.getCourseByID(GradesData.currCourseID).weighted.toString();
      }
      else{
        if(dropdownValueGrade=="Letter" && !_comp) {
          if(dropdownValueLetter==null){
            _showDialog("Choose a letter grade");
            return;
          }
          _addGrade = dropdownValueLetter;
          //
        }
        print("grade chosen is $_addGrade");
      }

      print("adding $_addCourse, $_addGrade");
      await gradesData.addCompleteCourseData(_addGrade);
      Navigator.pop(context,[true]);

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

    if (value.isEmpty && !_comp || (int.parse(value)>year) ) return 'Please enter a valid course year.';

    return null;
  }

  String _validateCourseGrade(String value) {
    if (value.isEmpty && !_comp) return 'Please enter a valid grade.';
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
            items: GPATable.grades.reversed
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
                labelText: !_comp? "Course grade": "" ,
              ),
              validator: this._validateCourseGrade,
              onSaved: (String value) {
                print("val is $value");
                _addGrade = value;
              }) );
    }
  }
  String checkBoxText(){
    String text = 'Is your final grade for ${gradesData.getCourseByID(GradesData.currCourseID).code}';

    if(dropdownValueGrade=="Letter"){
      return text + " an ${gradesData.getCourseByID(GradesData.currCourseID).letterGrade}?";
    }
    else{
      return text + " a ${gradesData.getCourseByID(GradesData.currCourseID).weighted}%?";
    }
  }

  Widget _buildForm(BuildContext context){
    return new Form(
        key: this._formKey,
        child: new Column(

          children: <Widget>[
            new CheckboxListTile(
              title: Text(checkBoxText(),
                style: TextStyle(
                  fontSize: 16.0 + fontScale,
                ),),
              value: _comp,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (bool value) {
                setState(() {
                  _addGrade = null;
                  dropdownValueLetter = null;
                  _comp = value;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),

            new Visibility(
                visible: !_comp,
                child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[

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
                              onChanged: !_comp ? (String newValue) => setState(() => dropdownValueGrade = newValue) : null,
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
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('Complete Course',
                        style: TextStyle(
                          fontSize: 16.0 + fontScale,
                        )
                    ),
                    onPressed: (){
                      completeCourse(context);
                    },
                  ),
                )
              ]
            )
          ],
        )
    );
  }
  bool checkFormFilled(){
    _formKey.currentState.save();
    if(dropdownValueGrade!="Letter" ||dropdownValueLetter!=null || _comp){
      return true;

    }
    return false;
  }

  Future<bool> _onWillPop() async {
    if(checkFormFilled()) {
      return (await showDialog(
        context: context,
        builder: (context) =>
        new AlertDialog(
          title: new Text('Quit'),
          content: new Text('Do you want to discard unsaved changes?'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: new Text('No'),
            ),
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: new Text('Yes'),
            ),
          ],
        ),
      )) ?? false;
    }
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _onWillPop,
          child: Scaffold(
        appBar: new AppBar(
            iconTheme: IconThemeData(
              color: Theme.of(context).primaryColor, //change your color here
            ),
            centerTitle: true,
            backgroundColor: Color(0x00000000),
            elevation: 0,
            title: Text('COMPLETE ${gradesData.getCourseByID(GradesData.currCourseID).code}')
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
      )
    );
  }
}

/*

 */