import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:googleapis/cloudbuild/v1.dart';
import '../../../UpdateApp/Subject/SettingsData.dart';
import 'package:study/GoogleAPI/Firestore/GradesFirestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../Subject/GradesData.dart';
import '../../Helper/GPATable.dart';
import '../../Helper/Course.dart';

class GradePredictorPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return GradePredictorState();
  }
}

class GradePredictorState extends State<GradePredictorPage> {

  bool submitted;
  String _goalGrade;
  String dropdownValueGrade;
  GradesData gradesData;
  String dropdownValueLetter;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  GradePredictorState(){
    submitted = false;
    print("in state constructor!");
    dropdownValueGrade = "Letter";
    gradesData = new GradesData();

  }

  void calculateGradeNeeded(){
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      String grade = '';
      if(dropdownValueGrade=="Letter"){
        if(dropdownValueLetter==null) {
          _showDialog("Choose a letter grade");
        }
        else{
          grade = dropdownValueLetter;
        }
      }
      else{
        grade = _goalGrade;
      }
      print("calculating...");
      setState(() {
        submitted = gradesData.calculateGradePredict(grade);

      });
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

  Widget _buildGradeForm(BuildContext context){

    if(dropdownValueGrade=="Letter"){
      return Container(
          child: DropdownButton<String>(

            hint: Text("Desired Letter grade"),
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
              style: TextStyle(
                fontSize: 16.0 + fontScale,
              ),
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                hintText: 'Enter grade from 0 to 100...',
                labelText: "Desired Grade *",
              ),
              validator: this._validateGradeGoal,
              onSaved: (String value) {
                print("val is $value");
                _goalGrade = value;
              }), );
    }
  }


  Widget _buildForm(BuildContext context){
    return new Form(
        key: this._formKey,
        child: new Column(

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
                    onChanged: (String newValue) => setState(() => dropdownValueGrade = newValue),
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
            SizedBox(
              width: double.infinity,
              child:  RaisedButton(

                child: Text('Run Predictor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0 + fontScale,
                    )
                ),
                onPressed: (){
                  calculateGradeNeeded();
                },
              ),
            )

          ],
        )
    );
  }

  Widget buildPredictBlock(BuildContext context){
    print("boolean expression is value of $submitted");
    if(!submitted){
      print("not submitted");
      return null;
    }

    return Padding(
        padding: EdgeInsets.all(10.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.1,
          height:  160,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("GRADE NEEDED",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),),
                ),
                Column(
                  children: infoColumn(),
                )
              ],
            ),

          ),
        )
    );

  }

  List<Widget> infoColumn(){
    if(gradesData.getCourseByID(GradesData.currCourseID).totalWeight>=100){
      return [
        Container(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(0.0),

            child: Text("Course is complete",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),),
          ),
        ),
      ];
    }
    else if(gradesData.gradeNeededPredict>100){
      return [
        Container(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(0.0),

            child: Text("Grade needed is greater than 100%",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),),
          ),
        ),
      ];
    }
    return [
      Container(
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(0.0),

              child: Text("${gradesData.gradeNeededPredict}%",
                style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),),
            ),
            Padding(
              padding: EdgeInsets.all(0.0),

              child: Text("For ${100-gradesData.getCourseByID(GradesData.currCourseID).totalWeight}% of the course",
                style: TextStyle(
                    fontSize: 16.0+fontScale,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),),
            ),
          ],
        )
      ),

    ];
  }

  String _validateGradeGoal(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    print("drop down is $dropdownValueGrade");
    if(dropdownValueGrade=="Letter")return null;
    if (value.isEmpty ) return 'Please enter a valid GPA.';
    if(double.parse(value)>100) return 'Please enter a GPA less than or equal to 100';
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
          title: Text('${gradesData.getCourseByID(GradesData.currCourseID).code} Grade Predictor',
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
                        buildPredictBlock(context),
                      ]
                  )
              ),
            ],
          )
      ),
    );
  }
}

