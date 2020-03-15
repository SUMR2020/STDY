import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:study/Grades/Helper/AuditItem.dart';
import '../Predictor/GPAPredictorPage.dart';
import 'CoursePage.dart';
import '../Input/CourseFormPage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../UpdateApp/Subject/SettingsData.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../Predictor/GPAPredictorPage.dart' as predict;
import '../../Subject/GradesData.dart';
import '../../Helper/Course.dart';


//https://api.flutter.dev/flutter/material/ExpansionPanelList-class.html
class AuditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AuditPageState();
  }
}

class AuditPageState extends State<AuditPage> {

  GradesData gradesData;
  Future <bool> _futureData;

  AuditPageState(){
    gradesData = new GradesData();
    _futureData = gradesData.fetchGradesData();

  }

  void _removeData(String courseID) async {
    print("course id for removal is $courseID");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm"),
          content: new Text("Are you sure you want to delete course $courseID?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () async{
                await gradesData.removeCourseData(courseID);

                setState(() {});

                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );



  }

  void _openCoursePage(String id) async {
    Course c = gradesData.getCourseByID(id);
    if(c.curr){
      GradesData.currCourseID = id;
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoursePage(),
          ));

    }

    else {
      _showDialog("Error", "Cannot add assignments to past course.");
    }

  }

  void _showDialog(String title, String content) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title,
            style: TextStyle(
              fontSize: 16.0 + fontScale,
            ),),
          content: new Text(content,
            style: TextStyle(
              fontSize: 16.0 + fontScale,
            ),),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close",
                style: TextStyle(
                  fontSize: 16.0 + fontScale,
                ),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addData() async {

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseInputPage(),
        ));

    setState(() {
      print("gpa in audit is ${GradesData.gpa}");

    });

  }


  List<Widget> _buildCourses(String semester, List<Course> courses){
    List<Widget> courseWidgets = <Widget>[];

    for(int i =0; i<courses.length; i++){
      //String grade = gradesData.firestore.getCourseGrade((courses[i].id+semester).replaceAll(' ',''));

      courseWidgets.add(
        ListTile(
            title: Text(courses[i].code,
              style: TextStyle(
                fontSize: 16.0 + fontScale,
              ),),
            subtitle: Text('Grade: ${courses[i].letterGrade}',
              style: TextStyle(
                fontSize: 16.0 + fontScale,
              ),),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Increase volume by 10',
              onPressed: () {
                _removeData(courses[i].id);
              },
            ),
            onTap: () {
              _openCoursePage(courses[i].id);
              setState(() {
              });
            }),


      );
    }

    return courseWidgets;

  }

  Widget _buildPanel()  {

    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          GradesData.auditItems[index].isExpanded = !isExpanded;
        });
      },
      children: GradesData.auditItems.map<ExpansionPanel>((AuditItem item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue,
                style: TextStyle(
                  fontSize: 16.0 + fontScale,
                ),),
              subtitle: Text('GPA: ${item.semGPA}',
                style: TextStyle(
                  fontSize: 16.0 + fontScale,
                ),),
            );
          },
          body: Container(
            child: Column(
              children: _buildCourses(item.headerValue, item.expandedText)
            )
              ),
          isExpanded: item.isExpanded,
        );

      }).toList(),
    );
  }

  Widget buildUserInfo(){
    return Container(
        child: Column(
            children: <Widget>[
              Text("Student Stats",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0 + fontScale,
                ),),
              Text("Actual GPA: ${GradesData.gpa}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0 + fontScale,
                ),),
              Text("Current GPA: ${GradesData.currGPA}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0 + fontScale,
                ),),

            ]
        )
    );
  }

  Widget projectWidget() {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (!projectSnap.hasData) {
          return Container(
            alignment: Alignment.center,
            child: SizedBox(
              height: 100,
              width: 100,
              child:  CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
             )
            )
          );
        }
        else {
          return Column(
            children: <Widget>[
              buildUserInfo(),
              _buildPanel(),
            ],
          );
        }
      },
      future: _futureData,
    );
  }


  void _openCoursePredictor() async {
    print("course pred opened");
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GPAPredictorPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    //return
    return
      Scaffold(

      floatingActionButton: SpeedDial(
        child: Icon(Icons.open_in_new),
        overlayOpacity: 0.0,
        children: [

          SpeedDialChild(
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).primaryColor,
            labelBackgroundColor: Theme.of(context).primaryColor,
            shape: CircleBorder(),
            label: 'New Course',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _addData(),
          ),
          SpeedDialChild(
            child: Icon(Icons.grade),
            backgroundColor: Theme.of(context).primaryColor,
            labelBackgroundColor: Theme.of(context).primaryColor,
            label: 'Predictor',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _openCoursePredictor(),
          ),

        ],

      ),


      body: SingleChildScrollView(

        child: projectWidget(),

      ),
    );
  }
}




