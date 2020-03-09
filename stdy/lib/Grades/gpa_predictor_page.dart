import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';
import 'package:study/Grades/Model/CourseData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class GPAPredictorPage extends StatefulWidget {

  List<DocumentSnapshot> courseData;
  GPAPredictorPage(this.courseData);

  @override
  State<StatefulWidget> createState() {
    return GPAPredictorState(this.courseData);
  }
}

class GPAPredictorState extends State<GPAPredictorPage> {

  List<DocumentSnapshot> courseData;
  List<String> addedCourseNames;
  List<Map<String, dynamic>> addedCourseData;
  String courseName;
  String sem;
  String id;
  int predictCount;
  CourseData firehouse;
  bool submitted;

  String _goalGPA;
  String dropdownValueGrade;
  String dropdownValueLetter;
  String temp;
  String gradeNeeded;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();


  GPAPredictorState(List<DocumentSnapshot> c){
    submitted = false;
    predictCount=0;
    addedCourseNames = <String>[];
    addedCourseData = <Map<String, dynamic>>[];
    courseData = c;
    dropdownValueGrade = "Letter";

    firehouse = new CourseData();

    for(int i =0; i<courseData.length; i++) {
      String id = courseData[i].data["id"];
      if(courseData[i].data["taken"]=="CURR"){
        predictCount+=1;
      }

    }
    print("coutn is $predictCount");


  }

  void calculateGPANeeded(){
    if (this._formKey.currentState.validate()) {

      _formKey.currentState.save();
      double gpaNeed = double.parse(firehouse.findNumberGPA(double.parse(_goalGPA)));
      double gpa=0.0;

      for(int i =0; i<courseData.length; i++){
        if(courseData[i].data["taken"]!="CURR" && !addedCourseNames.contains(id)) {
          String grade = firehouse.findNumberGPA(courseData[i].data["grade"]);
          //print(courseData[i].data["id"]);
          gpa+= double.parse(grade);

        }

      }

      for(int i =0; i<addedCourseData.length; i++){
        String grade;
        if(addedCourseData[i]["gradeOption"]=="Letter"){
          grade = firehouse.grades.indexOf(addedCourseData[i]["inGrade"]).toString();
        }
        else if(addedCourseData[i]["gradeOption"]=="Percentage"){
          grade = firehouse.findNumberGPA(double.parse(addedCourseData[i]["inGrade"]));
        }
        else{
          grade = firehouse.findNumberGPA(addedCourseData[i]["weighted"]);
        }
          print(grade);
          gpa+= double.parse(grade);

        }
      print(double.parse(_goalGPA));
      setState(() {
        gradeNeeded = ( ( (gpaNeed*courseData.length)-gpa )/predictCount ).toString();
        print("total past grade is $gpa");
        submitted= true;
      });

    }

  }

  String _validateCourseGrade(String value) {
    if (value.isEmpty) return 'Please enter a valid grade.';
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    //if (value.isEmpty) return 'Please enter a valid course grade.';
    return null;
  }

  Widget _buildGradeForm(BuildContext context, Map<String, dynamic> course){

    if(course["gradeOption"]=="Letter"){
      return Container(
          child: DropdownButton<String>(

            hint: Text("Letter grade",style: TextStyle(
              fontSize: 16.0 + fontScale,
            ),),
            value: course["inGrade"],
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(
              color: stdyPink,
              fontSize: 16.0+fontScale,
            ),
            underline: Container(
              height: 2,
              color: stdyPink,

            ),
            onChanged: (String newValue) {
              setState(() {
                course["inGrade"] = newValue;
              });
            },
            items: firehouse.grades.reversed
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
    else if(course["gradeOption"]=="Current"){
      return Text("                   ${course["weighted"]}",
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
                course["inGrade"] = value;
              }) );
    }
  }

  List<Widget> _buildCurrCourses(BuildContext context){
    List<Widget> courseWidgets = <Widget>[];

    for(int i =0; i<addedCourseData.length; i++) {
      List<String> dropDown = ["Current", "Letter", "Percentage"];
      if(addedCourseData[i]["weighted"]==null){
        dropDown.remove("Current");
      }


      courseWidgets.add(

          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("${addedCourseData[i]["id"]}:",
                  style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  ),),
                SizedBox(width: 10),
                DropdownButton<String>(
                  hint: Text("Type",style: TextStyle(
                    fontSize: 16.0 + fontScale,
                  ),),
                  value: addedCourseData[i]["gradeOption"],
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(
                    color: stdyPink,
                    fontSize: 16.0 + fontScale,
                  ),
                  underline: Container(
                    height: 2,
                    color: stdyPink,
                  ),
                  onChanged: (String newValue) =>
                      setState(() => addedCourseData[i]["gradeOption"] = newValue),
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
                _buildGradeForm(context,addedCourseData[i]),

                IconButton(
                  icon: Icon(Icons.delete),
                  color: stdyPink,
                  tooltip: 'Increase volume by 10',
                  onPressed: () {
                     _removeCurrentCourse(addedCourseData[i]);

                  },
                ),


              ]
          )
      );
    }
    return courseWidgets;

  }

  void _removeCurrentCourse(Map<String, dynamic> course){
    setState(() {
      addedCourseNames.remove(course["id"]);
      addedCourseData.removeWhere((item) => item["id"] == course["id"]);
      predictCount+=1;

    });

  }
  void _addCurrentCourse(Map<String, dynamic> course){

    if(predictCount==1){
     // _showDialog("Need at least one current course to predict GPA");
    }

    setState(() {
      //course["gradeOption"] = 'Current';
      //course["inGrade"] ='';
      addedCourseNames.add(course["id"]);
      addedCourseData.add(course);
      predictCount-=1;
    });

  }
  List<SpeedDialChild> floatingCourseButtons(BuildContext context){
    List<SpeedDialChild> courseButtons= <SpeedDialChild>[];

    for(int i =0; i<courseData.length; i++) {
      String id = courseData[i].data["id"];
      if(courseData[i].data["taken"]=="CURR" && !addedCourseNames.contains(id)){
        courseButtons.add(
          SpeedDialChild(
            child: Icon(Icons.add),
            backgroundColor: stdyPink,
            labelBackgroundColor: stdyPink,
            shape: CircleBorder(),
            label: 'Grade $id',

            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _addCurrentCourse(courseData[i].data),
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
                    Text("Grades needed is: $gradeNeeded", style: TextStyle(
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

