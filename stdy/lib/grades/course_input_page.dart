import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';

class CourseInputPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CourseInputState();
  }
}

class CourseInputState extends State<CourseInputPage>{

  var _addYear = TextEditingController();
  var _addCourse = TextEditingController();

  String dropdownValue;

  CourseInputState(){
    dropdownValue = "Semester";
  }

  void addCourseButton(BuildContext context){
    print(dropdownValue);
    Navigator.pop(context, [_addCourse.text,  dropdownValue,_addYear.text]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new course"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Course Name"),
            new SizedBox( child: TextField(controller: _addCourse,
              decoration: new InputDecoration(),
            )),
            Text("Course Year"),
            new SizedBox(child: TextField(controller: _addYear,
              decoration: new InputDecoration(),keyboardType: TextInputType.number
            )),
            Text("Course Semester"),
          DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(
                color: stdyPink
            ),
            underline: Container(
              height: 2,
              color: stdyPink,
            ),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: <String>["Semester","Fall", "Winter", "Summer"]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            })
                .toList(),
          ),



            RaisedButton(
              child: Text('Add course'),
              onPressed: (){
                addCourseButton(context);
              },
            ),

          ],
        )

      ),
    );
  }
}
