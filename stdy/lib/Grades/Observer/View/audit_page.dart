import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../Predictor/gpa_predictor_page.dart';
import '../../../Schedule/TaskData.dart';
import 'course_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Input/course_input_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../../../main.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../Predictor/gpa_predictor_page.dart' as predict;
import 'package:study/Grades/Subject/GradeData.dart';

//https://api.flutter.dev/flutter/material/ExpansionPanelList-class.html
class GradesYearPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GradesYearPageState();
  }
}

class GradesYearPageState extends State<GradesYearPage> {


  CourseData firehouse;

  int marks;

  List<Item> _data;

  List<DocumentSnapshot> courseData;

  Future <List<DocumentSnapshot>> _futureData;
  double actualGPA;
  double currentGPA;


  GradesYearPageState(){
    firehouse = new CourseData();

    marks = 0;

    _futureData = _getData();

  }


  List<Item> generateItems(Map<String, List<Map<String, dynamic>>> data) {
    List<Item> items = <Item>[];

    List<String> sortedKeys = data.keys.toList();

    sortedKeys.forEach((key) =>
        items.add(
            Item(
                headerValue: key.toString(),
                expandedValue: "This is a value thing",
                expandedText: data[key],
                semGPA: firehouse.calculateSemGPA(key, data[key].length)
            )
        )
    );



    return items;
  }


  void _removeData(String course, String semester) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm"),
          content: new Text("Are you sure you want to delete course $course?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () async{
                await firehouse.remove_course((course + semester).replaceAll(' ', ''));
                await _getData();
                firehouse.calculateGPA(courseData);
                await _getData();
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

  void _openCoursePage(Map<String, dynamic> course) async {
    //print("grade is $grade");
    if(course["taken"]=="CURR"){
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GradesPage(course),
          ));

      print("course data with size of ${courseData.length}");
      _getData();


      setState(() {});

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

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseInputPage(),
        ));

    print(result);
    await firehouse.addData(result);

    await _getData();
    firehouse.calculateGPA(courseData);
    await _getData();
    setState(() {});

  }
  double t;

  Future <List<DocumentSnapshot>> _getData() async {
    courseData =  await firehouse.getCourseData();
    print ("After get course data");
    actualGPA =  await firehouse.getGPA(false);
    print ("After currGPA data");
    currentGPA = await firehouse.getGPA(true);
    print ("After actualGPA data");
    actualGPA = double.parse(actualGPA.toStringAsFixed(2));
    currentGPA = double.parse(currentGPA.toStringAsFixed(2));
    print("future 1 done");

    Map<String, List<Map<String, dynamic>>> courseByYear = firehouse.getCourseNameSem(courseData);

    print("gpa is now $t, $currentGPA");
    _data = generateItems(courseByYear);
    setState(() {
    });

    return courseData;
  }



  List<Widget> _buildCourses(String semester, List<Map<String, dynamic>> courses){
    List<Widget> courseWidgets = <Widget>[];

    for(int i =0; i<courses.length; i++){
      String grade = firehouse.getCourseGrade((courses[i]["id"]+semester).replaceAll(' ',''));

      courseWidgets.add(
        ListTile(
            title: Text(courses[i]["id"],
              style: TextStyle(
                fontSize: 16.0 + fontScale,
              ),),
            subtitle: Text('Grade: $grade',
              style: TextStyle(
                fontSize: 16.0 + fontScale,
              ),),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Increase volume by 10',
              onPressed: () {
                _removeData(courses[i]["id"], semester);
              },
            ),
            onTap: () {
              _openCoursePage(courses[i]);
              setState(() {
                print("course opened");
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
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
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


  Widget projectWidget() {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (!projectSnap.hasData) {
          print('project snapshot data is: ${projectSnap.data}');
          return CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          );
        }
        else {
          return _buildPanel();
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
          builder: (context) => GPAPredictorPage(courseData),
        ));
  }

  @override
  Widget build(BuildContext context) {
    print('in build');
    return Scaffold(

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

        child: Column(
          children: <Widget>[

            Container(
              child: Column(
                children: <Widget>[
                  Text("Student Stats",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0 + fontScale,
                    ),),
                  Text("Actual GPA: $actualGPA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0 + fontScale,
                    ),),
                  Text("Current GPA: $currentGPA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0 + fontScale,
                    ),),

                ]
              )
            ),
            Container(child: projectWidget()),
          ],

        ),

      ),
    );
  }
}

class Item {
  Item({
    this.expandedValue,
    this.headerValue,
    this.expandedText,
    this.isExpanded = false,
    this.semGPA
  });

  String expandedValue;
  String headerValue;
  List<Map<String, dynamic>> expandedText;
  bool isExpanded;
  String semGPA;
}


