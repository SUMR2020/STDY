import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:study/main.dart';
import 'grades/grades_data.dart';

Future<bool> _CoursesLoaded;

class TaskPage extends StatefulWidget {
  String taskType;
  int index;
  TaskPage(String t, int i) {
    taskType = t;
    index = i;
  }
  @override
  State<StatefulWidget> createState() => new _TaskPageState(taskType, index);
}

class _Data {
  String name = '';
  String length = '';
  DateTime dueDate;
  List<DateTime> dates;
  String dropDownValue;
  bool monVal = false;
  bool tuVal = false;
  bool wedVal = false;
  bool thurVal = false;
  bool friVal = false;
  bool satVal = false;
  bool sunVal = false;
  String getDropDownValue() {
    return dropDownValue;
  }

  void setDropDownValue(String d) {
    dropDownValue = d;
  }
}

class _TaskPageState extends State<TaskPage> {
  String taskType;
  int index;
  GradeData grades = new GradeData();
  List<DocumentSnapshot> courses;
  List<String> courseNames = List<String>();

  List<String> tasks = [
    "pages of reading.",
    "estimated time to spend on the assignment.",
    "estimated time to spend on the project.",
    "amount of time to spend on lectures.",
    "amount of time to spend writing notes."
  ];

  List<String> tasks1 = [
    "Amount of pages",
    "Estimated time (h)",
    "Estimated time (h)",
    "Amount of time (h)",
    "Estimated time (h)"
  ];

  _TaskPageState(String t, int i) {
    taskType = t;
    index = i;
    _CoursesLoaded = getCourses();
  }

  Future<bool> getCourses() async {
    courses = await grades.getCourseNames();
    courses.forEach((data) => print(data.data["id"]));
    courses.forEach((data) => courseNames.add(data.data["id"]));
    return true;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _Data _data = new _Data();
  DateTime selectedDate = DateTime.now();
  String _validateName(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    if (value.isEmpty) return 'Please enter a valid name.';
    return null;
  }

  String _validateAmount(String value) {
    if (!isNumeric(value)) return 'Please enter a valid number.';
    return null;
  }

  void submit() {
    // First validate form.
    if (_data.dueDate == null && _data.dropDownValue == null) {
      print("in if");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Please select a due date and course.'),
            );
          });
    } else if (_data.dueDate == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Please select a due date.'),
            );
          });
    } else if (_data.dropDownValue == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Please select a course.'),
            );
          });
    } else {
      if (this._formKey.currentState.validate()) {
        _formKey.currentState.save(); // Save our form now.
        print('Printing the login data.');
        print('Email: ${_data.name}');
        print('Password: ${_data.length}');
        print('due date: ${_data.dueDate.toString()}');
        print('course: ${_data.dropDownValue}');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => TaskPage(taskType, index)));
      } else {
        print("not valid");
      }
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        print(picked);
        _data.dueDate = picked;
      });
  }

  Widget checkbox(String title, bool boolValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(title),
        Checkbox(
          activeColor: stdyPink,
          value: boolValue,
          onChanged: (bool value) {
            /// manage the state of each value
            setState(() {
              switch (title) {
                case "Mon":
                  _data.monVal = value;
                  break;
                case "Tues":
                  _data.tuVal = value;
                  break;
                case "Wed":
                  _data.wedVal = value;
                  break;
                case "Thur":
                  _data.thurVal = value;
                  break;
                case "Fri":
                  _data.friVal = value;
                  break;
                case "Sat":
                  _data.satVal = value;
                  break;
                case "Sun":
                  _data.sunVal = value;
                  break;
              }
            });
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Color(0x00000000),
        elevation: 0,
        title: Text('INFORMATION FOR ' + taskType),
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            key: this._formKey,
            child: new ListView(
              children: <Widget>[
                new TextFormField(
                    decoration: new InputDecoration(
                      hintText: 'Enter name here...',
                      labelText: taskType[0].toUpperCase() +
                          taskType.substring(1).toLowerCase() +
                          " name",
                    ),
                    validator: this._validateName,
                    onSaved: (String value) {
                      this._data.name = value;
                    }),
                new TextFormField(
                    decoration: new InputDecoration(
                      hintText: "Please enter " + tasks[index],
                      labelText: tasks1[index],
                    ),
                    validator: this._validateAmount,
                    onSaved: (String value) {
                      this._data.length = value;
                    }),
                new Container(
                    child: FutureBuilder(
                        future: _CoursesLoaded,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return DropdownButton<String>(
                              hint: Text(
                                "Select course",
                              ),
                              value: _data.getDropDownValue(),
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 24,
                              isExpanded: true,
                              elevation: 16,
                              style: TextStyle(color: stdyPink),
                              underline: Container(
                                height: 2,
                                color: stdyPink,
                              ),
                              onChanged: (String newValue) {
                                setState(() {
                                  _data.setDropDownValue(newValue);
                                });
                              },
                              items: courseNames.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            );
                          } else {
                            return new Container();
                          }
                        })),
                Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: new Text(
                      "Selected due date:                                                    " +
                          (_data.dueDate.toString() == "null"
                              ? ""
                              : _data.dueDate.day.toString().padLeft(2, "0") +
                                  "-" +
                                  _data.dueDate.month
                                      .toString()
                                      .padLeft(2, "0") +
                                  "-" +
                                  _data.dueDate.year
                                      .toString()
                                      .padLeft(2, "0")),
                    )),
                RaisedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select due date'),
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        checkbox("Mon", _data.monVal),
                        checkbox("Tues", _data.tuVal),
                        checkbox("Wed", _data.wedVal),
                        checkbox("Thur", _data.thurVal),
                        checkbox("Fri", _data.friVal),
                        checkbox("Sat", _data.satVal),
                        checkbox("Sun", _data.sunVal),
                      ],
                    ),
                  ],
                ),
                new Container(
                  width: screenSize.width,
                  child: new RaisedButton(
                    child: new Text(
                      'Submit',
                      style: new TextStyle(color: Colors.white),
                    ),
                    onPressed: this.submit,
                    color: stdyPink,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                ),
              ],
            ),
          )),
    );
  }
}
