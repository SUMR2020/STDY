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
  var _addGrade = TextEditingController();

  String dropdownValueSem;

  CourseInputState(){
    dropdownValueSem = "Semester";
  }

  void addCourseButton(BuildContext context){
    String grade = _addGrade.text;

    if(dropdownValueSem=="Semester" ||
        _addCourse.text=='' || _addYear.text==''
    ){
      _showDialog();
      return;
    }

    if(grade==''){
      grade = 'CURR';
    }

    print(dropdownValueSem);
    Navigator.pop(context, [_addCourse.text,  dropdownValueSem,_addYear.text, grade]);
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text("One of the input fields is empty."),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text('INPUT COURSE')
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
                isExpanded: true,
                value: dropdownValueSem,
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
                    dropdownValueSem = newValue;
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

              Text("Grade (Leave blank for CURR)"),
              new SizedBox(child: TextField(controller: _addGrade,
                  decoration: new InputDecoration(hintText: "0-100%"),keyboardType: TextInputType.number
              )),



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
