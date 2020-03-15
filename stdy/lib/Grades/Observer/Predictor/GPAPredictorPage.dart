import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../UpdateApp/Subject/SettingsData.dart';
import 'package:study/GoogleAPI/Firestore/GradesFirestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../Subject/GradesData.dart';
import '../../Helper/GPATable.dart';
import '../../Helper/Course.dart';

class GPAPredictorPage extends StatefulWidget {

  GPAPredictorPage();

  @override
  State<StatefulWidget> createState() {
    return GPAPredictorState();
  }
}

class GPAPredictorState extends State<GPAPredictorPage> {

  bool submitted;
  String _goalGPA;
  String dropdownValueGrade;
  GradesData gradesData;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  GPAPredictorState(){
    submitted = false;
    dropdownValueGrade = "Letter";
    gradesData = new GradesData();
    gradesData.calculateCoursePredictCount();

  }

  void calculateGPANeeded(){
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        submitted = gradesData.calculateGPAPredict(_goalGPA);
      });
    }
  }

  String _validateCourseGrade(String value) {
    if (value.isEmpty) return 'Please enter a valid grade.';
    return null;
  }

  Widget _buildGradeForm(BuildContext context, Course course){

    if(course.gradeOption=="Letter"){
      return Container(
          child: DropdownButton<String>(

            hint: Text("Letter grade",style: TextStyle(
              fontSize: 16.0 + fontScale,
            ),),
            value: course.inGrade,
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
                course.inGrade = newValue;
              });
            },
            items: GPATable.grades.reversed
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,style: TextStyle(
                  fontSize: 16.0 + fontScale,
                ),),
              );
            })
                .toList(),
          )
      );
    }
    else if(course.gradeOption=="Current"){
    return Text("                   ${course.weighted}",
        style: TextStyle(
          fontSize: 16.0 + fontScale,
        ),);
    }
    else{
      return new Flexible(
          child: new TextFormField(
              textAlign: TextAlign.end,
              keyboardType:TextInputType.number,
              decoration: new InputDecoration(
                hintText: 'Enter course grade here...',
                labelText: "Course %" ,
              ),
              validator: this._validateCourseGrade,
              onSaved: (String value) {
                print("val is $value");
                course.inGrade = value;
              }) );
    }
  }

  List<Widget> _buildCurrCourses(BuildContext context){
    List<Widget> courseWidgets = <Widget>[];

    for(int i =0; i<gradesData.currCoursePredict.length; i++) {
      List<String> dropDown = ["Current", "Letter", "Percentage"];
      if(gradesData.currCoursePredict[i].weighted==null){
        dropDown.remove("Current");
      }

      courseWidgets.add(

          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("${gradesData.currCoursePredict[i].code}:",
                  style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  ),),
                SizedBox(width: 10),
                DropdownButton<String>(
                  hint: Text("Type",style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  ),),
                  value: gradesData.currCoursePredict[i].gradeOption,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16.0 + fontScale,
                  ),
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                  onChanged: (String newValue) =>
                      setState(() => gradesData.currCoursePredict[i].gradeOption = newValue),
                  /*_curr? (String newValue) {

                          setState(() {
                            dropdownValueGrade = newValue;
                          });
                        }: null,*/
                  items: dropDown
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                      .toList(),
                ),
                SizedBox(width: 10),
                _buildGradeForm(context,gradesData.currCoursePredict[i]),

                IconButton(
                  icon: Icon(Icons.delete),
                  color: Theme.of(context).primaryColor,
                  tooltip: 'Increase volume by 10',
                  onPressed: () {
                    setState(() {
                     gradesData.removeCurrCoursePredict(i);
                    });


                  },
                ),


              ]
          )
      );
    }
    return courseWidgets;

  }



  List<SpeedDialChild> floatingCourseButtons(BuildContext context){
    List<SpeedDialChild> courseButtons= <SpeedDialChild>[];

    for(int i =0; i<GradesData.courses.length; i++) {
      String code = GradesData.courses[i].code;
      if(GradesData.courses[i].curr && !gradesData.checkCurrCoursePredictExists(i)){
        print("hello added b");
        courseButtons.add(
          SpeedDialChild(
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).primaryColor,
            labelBackgroundColor: Theme.of(context).primaryColor,
            shape: CircleBorder(),
            label: 'Grade $code',

            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                bool added = gradesData.addCurrCoursePredict(i);
                if(!added){
                  _showDialog("Need at least one current course to predict GPA");
                }
              });

            }
          ),


        );

      }
    }



    return courseButtons;
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

  Widget _buildForm(BuildContext context){
    return new Form(
        key: this._formKey,
        child: new Column(

          children: <Widget>[

            new TextFormField(
                style: TextStyle(
                  fontSize: 16.0 + fontScale,
                ),
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                  hintText: 'Enter desired GPA...',
                  labelText: "Desired GPA *",
                ),
                validator: this._validateGPAGoal,
                onSaved: (String value) {
                  print("val is $value");
                  _goalGPA = value;
                }),

            new Container(
                child: new Column(
                    children: _buildCurrCourses(context)
                  )

                ),

            RaisedButton(
              child: Text('Run Predictor',
                  style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  )
              ),

              onPressed: (){
                calculateGPANeeded();
              },
            ),


          ],
        )
    );
  }

  String _validateGPAGoal(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    if (value.isEmpty ) return 'Please enter a valid GPA.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        child: Icon(Icons.open_in_new),
        overlayOpacity: 0.0,
        children: floatingCourseButtons(context),

      ),
      appBar: new AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColor, //change your color here
          ),
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text('GPA Predictor',
          )
      ),

      body: SingleChildScrollView(
          padding: new EdgeInsets.all(20.0),
          child: new Column(
            children: <Widget>[
              _buildForm(context),

              new Visibility(
                visible: submitted,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Text("Grades needed is: ${gradesData.gpaNeededPredict}", style: TextStyle(
                      fontSize: 16.0 + fontScale,
                    ))
                  ]
                )
              ),

            ],
          )
      ),
    );
  }

}

