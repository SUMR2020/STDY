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
      List<String> dropDown;
      if(gradesData.currCoursePredict[i].weighted==0){
        dropDown = ["Letter", "Percentage"];
      }
      else{
        dropDown = ["Current","Letter", "Percentage"];
      }
      print("drop down contains $dropDown");

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
                  hintText: 'Enter desired GPA from 0 to 12.0...',
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
                calculateGPANeeded();
              },
            ),
          )

          ],
        )
    );
  }

  Widget buildPredictBlock(BuildContext context){
    if(!submitted){
      print("not submitted");
      return null;
    }
    int index = double.parse(gradesData.gpaNeededPredict).ceil();
    double hei = 160;
    print("index is $index");
    if(index<=12){
      hei+=double.parse((50*gradesData.predictCount).toString());
    }
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.1,
          height:  hei,
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
                  children: infoColumn(index),
                )
              ],
            ),

          ),
        )
    );

  }

  List<Widget> infoColumn(index){
    if(index>=12){
      return [
        Container(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(0.0),

            child: Text("Grade needed greater than A+",
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
        child: Padding(
          padding: EdgeInsets.all(0.0),

          child: Text(GPATable.grades[index],
            style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),),
        ),
      ),
      Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Text("For each of the following courses",
                style: TextStyle(
                  fontSize: 18.0+fontScale,
                  color: Colors.white,
                ),),

            ],
          )
      ),
      Column(
        children:  courseColumn(),
      )
    ];
  }


  List<Widget> courseColumn(){
    List<Widget> temp = <Widget>[];
    List<Course> courses = gradesData.getCurrPredictCourses();

    for(int i =0; i<courses.length; i++){
      temp.add(
          Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Text(courses[i].code,
                    style: TextStyle(
                      fontSize: 18.0+fontScale,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),),

                ],
              )
          )
      );

    }
    return temp;

  }


  String _validateGPAGoal(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    if (value.isEmpty ) return 'Please enter a valid GPA.';
    if(double.parse(value)>12) return 'Please enter a GPA less than or equal to 12.0';
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

