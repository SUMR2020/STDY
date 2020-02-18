import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'grades_data.dart';
import 'grades_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'course_input_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../main.dart';

//https://api.flutter.dev/flutter/material/ExpansionPanelList-class.html
class GradesYearPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GradesYearPageState();
  }
}

class GradesYearPageState extends State<GradesYearPage> {


  GradeData firehouse;

  int marks;
  String _finalGradeText;
  List<Item> _data; /*= <Item> [
    Item(headerValue: "test1", expandedValue: "IT WORKED", isExpanded: false)
  ];*/
  //String get grade => _grade.text;
  static Widget _expansionPane;
  List<DocumentSnapshot> courseData;

  Future <List<DocumentSnapshot>> _futureData;
  String gpaPageVal;



  GradesYearPageState(){
    firehouse = new GradeData();

    _finalGradeText = '';
    marks = 0;

    _futureData = _getData();

  }


  List<Item> generateItems(Map<String, List<String>> data) {
    List<Item> items = <Item>[];

    //List<String> sortedKeys = new List();
    //data.forEach((k, v) => sortedKeys.add(k));

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


  void _setPageStats(){
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
                await firehouse.remove_data((course + semester).replaceAll(' ', ''));
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

  void _openCoursePage(String course, String sem) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GradesPage(course, sem),
        ));



  }

  void _addData() async {

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseInputPage(),
        ));

    await firehouse.addData(result);

    await _getData();
    setState(() {});

  }

  Future <List<DocumentSnapshot>> _getData() async {

    courseData =  await firehouse.getCourseData();

    Map<String, List<String>> courseByYear = firehouse.getCourseNameSem(courseData);
    gpaPageVal = firehouse.getGPA().toStringAsFixed(2);
    print("gpa is now $gpaPageVal");
    _data = generateItems(courseByYear);
    setState(() {
    });


    return courseData;

  }

  List<Widget> _buildCourses(String semester, List<String> courses){
    List<Widget> courseWidgets = <Widget>[];

    for(int i =0; i<courses.length; i++){
      String grade = firehouse.getCourseGrade((courses[i]+semester).replaceAll(' ',''));
      print(grade);

      courseWidgets.add(
        ListTile(
            title: Text(courses[i]),
            subtitle: Text('Grade: $grade'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Increase volume by 10',
              onPressed: () {
                _removeData(courses[i], semester);
              },
            ),
            onTap: () {
              _openCoursePage(courses[i], semester);
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
              title: Text(item.headerValue),
              subtitle: Text('GPA: ${item.semGPA}'),
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
          //print('project snapshot data is: ${projectSnap.data}');
          return CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(stdyPink),
          );
        }
        else {
          return _buildPanel();
        }
      },
      future: _futureData,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('in build');
    return Scaffold(
      body: SingleChildScrollView(

        child: Column(
          children: <Widget>[

            RaisedButton(
              child: Text('Add new course'),
              onPressed: (){
                _addData();
              },
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Text("Student Stats"),
                  Text("GPA: $gpaPageVal"),

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
  List<String> expandedText;
  bool isExpanded;
  String semGPA;
}


