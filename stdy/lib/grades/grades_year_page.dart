import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'grades_data.dart';
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
  var _addYear = TextEditingController();
  var _addCourse = TextEditingController();
  List<Item> _data; /*= <Item> [
    Item(headerValue: "test1", expandedValue: "IT WORKED", isExpanded: false)
  ];*/
  //String get grade => _grade.text;
  static Widget _expansionPane;
  List<DocumentSnapshot> courseData;

  Future <List<DocumentSnapshot>> _futureData;



  GradesYearPageState(){
    firehouse = new GradeData();

    _finalGradeText = '';
    marks = 0;
     print("hello test");


    _futureData = _getData();

  }

  List<Item> generateItems(Map<String, List<String>> data) {
    List<Item> items = <Item>[];

    List<String> sortedKeys = data.keys.toList()..sort();

    sortedKeys.forEach((key) =>
        //print(key)
        items.add(
            Item(
                headerValue: key.toString(),
                expandedValue: "This is a value thing",
                expandedText: data[key]
            )
        )
    );
    /*
    print("test:");
    for(int i =0; i<items.length; i++){
      print(items[i].headerValue);
      print(items[i].expandedText);
    }
    print("test:");
    */

    return items;
  }

  void _removeData(String course, String semester) async{
    await firehouse.remove_data((course+semester).replaceAll(' ',''));

    await _getData();
    print("in add course");
    setState(() {});
    
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
    print("in add course");
    setState(() {});

  }

  Future <List<DocumentSnapshot>> _getData() async {

    courseData =  await firehouse.getCourseNames();

    print("testing course");
    Map<String, List<String>> courseByYear = firehouse.getCourseByYear(courseData);
    //courseByYear.forEach((key,val) => print(key));

    _data = generateItems(courseByYear);

    _data.forEach((i) =>
        print(i.headerValue)
    );

    return courseData;

  }

  List<Widget> _buildCourses(String semester, List<String> courses){
    List<Widget> courseWidgets = <Widget>[];

    for(int i =0; i<courses.length; i++){
      courseWidgets.add(
        ListTile(
            title: Text(courses[i]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Increase volume by 10',
              onPressed: () {
                _removeData(courses[i], semester);
              },
            ),
            onTap: () {
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

  /*



   body: Container(
              child: Column(
                  children: _buildCourses(item.expandedText)
              ),
          isExpanded: item.isExpanded,
        );

  body: ListTile(
              title: Text(item.expandedValue),
              subtitle: Text('To delete this panel, tap the trash can icon'),
              trailing: Icon(Icons.delete),
              onTap: () {
                setState(() {
                  _data.removeWhere((currentItem) => item == currentItem);
                });
              }),
          isExpanded: item.isExpanded,
        );
   */

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
  });

  String expandedValue;
  String headerValue;
  List<String> expandedText;
  bool isExpanded;
}


