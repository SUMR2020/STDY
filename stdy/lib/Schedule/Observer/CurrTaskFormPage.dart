import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:study/Schedule/Observer/SchedulePage.dart';
import '../../HomePage.dart';
import '../../UpdateApp/Subject/SettingsData.dart';
import '../Helper/Task.dart';
import '../Subject/TaskData.dart';

/*
CurrTaskFormPage
This is the underlying page we are building on.
    _index: the index of which type of task it is (1 is reading)
    _taskType: the name of the task type (reading)

_CurrTaskFormPageState
Class that creates a form for adding a new task and saves the data to be parsed
and sent to the database, this is an extension of the CurrTaskFormPage, as it is
a state of the CurrTaskForm. This is where the form is built.
     _coursesLoaded: if the course has been loaded by db
     _taskType: the task type
     _index: the index of the type
     _grades: the DAO object for accessing DB
     _courseNames: course names
     _tasks, _tasks1: different variations of working in the form based off type
     _data: the form data

FormData
A helper class to store the form data after it has been submitted.
    _name = name of the task to be added
    _length = time/pages of the task to be added
    _dueDate = the due date of the task to be added
    _forMarks = if the task is for marks
    _bonus = if the task is a bonus
    _dates = the dates that this task will be worked on
    _dropDownValue = the course selected for this task
    _monVal, _tuVal, _wedVal, _thurVal,
    _friVal, _satVal, _sunVal: the day of the week where this task will be worked on
*/

// Creating the underlying page, this gets sent the task type so we send that on to the form
class CurrTaskFormPage extends StatefulWidget {
  String _taskType;
  int _index;
  CurrTaskFormPage(String t, int i) {
   _taskType = t;
    _index = i;
  }
  @override
  // sending the task type and index to the form
  State<StatefulWidget> createState() => new _CurrTaskFormPageState(_taskType, _index);
}


// the helper FormData class, defined and explained aboce
class FormData {
  String _name = '';
  String length = '';
  DateTime _dueDate;
  bool _forMarks = false;
  bool _bonus = false;
  List<DateTime> _dates = List<DateTime>();
  String _dropDownValue;
  bool _monVal = false;
  bool _tuVal = false;
  bool _wedVal = false;
  bool _thurVal = false;
  bool _friVal = false;
  bool _satVal = false;
  bool _sunVal = false;

  // getting and setting the drop down value
  String getDropDownValue() {
    return _dropDownValue;
  }
  void setDropDownValue(String d) {
    _dropDownValue = d;
  }
}

// The class that creates the form
class _CurrTaskFormPageState extends State<CurrTaskFormPage> {
  // if the courses have been read in from the database (this is async)
  Future<bool> _coursesLoaded;
  // the task type and index of the task
  String _taskType;
  int _index;
  // accessing the database through the taskdata DAO
  TaskData _grades = new TaskData();
  // the course information
  List<String> _courseNames = List<String>();
  // lists of ways to ask for the amount based off type index
  List<String> _tasks = [
    "pages of reading.",
    "estimated time to spend on the assignment.",
    "estimated time to spend on the project.",
    "amount of time to spend on lectures.",
    "amount of time to spend writing notes."
  ];

  List<String> _tasks1 = [
    "Amount of pages",
    "Estimated time (h)",
    "Estimated time (h)",
    "Amount of time (h)",
    "Estimated time (h)"
  ];

  // ctor for the class
  _CurrTaskFormPageState(String t, int i) {
    _taskType = t;
   _index = i;
    _coursesLoaded = getCourses();
  }

  // getting course objs from DAO and
  Future<bool> getCourses() async {
   _courseNames = await _grades.getCourseNameList();
    return true;
  }

  // the formstate
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  FormData _data = new FormData();
  DateTime selectedDate = DateTime.now();

  // Validate functions form the name, to do amount
  String _validateName(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    if (value.isEmpty) return 'Please enter a valid name.';
    return null;
  }

  String _validateAmount(String value) {
    if (!Task.Empty().isNumeric(value)) return 'Please enter a valid number.';
    return null;
  }

  void submit() {
    // First validate form.
    if (_data._dueDate == null && _data._dropDownValue == null) {
      print("in if");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Please select a due date and course.'),
            );
          });
    } else if (_data._dueDate == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Please select a due date.'),
            );
          });
    } else if (_data._dropDownValue == null) {
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
        // updating all the data
        List<int> done;
        final daysToGenerate = _data._dueDate.difference(DateTime.now()).inDays + 2;
        var dates = List.generate(daysToGenerate, (i) => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + (i)));
        for (DateTime date in dates){

          if ((date.weekday == 1) && (_data._monVal == true)) _data._dates.add(date);
          if ((date.weekday == 2) && (_data._tuVal == true)) _data._dates.add(date);
          if ((date.weekday == 3) && (_data._wedVal == true)) _data._dates.add(date);
          if ((date.weekday == 4) && (_data._thurVal == true)) _data._dates.add(date);
          if ((date.weekday == 5) && (_data._friVal == true)) _data._dates.add(date);
          if ((date.weekday == 6) && (_data._satVal == true)) _data._dates.add(date);
          if ((date.weekday == 7) && (_data._sunVal == true)) _data._dates.add(date);
        }
        double dailyDouble = int.parse(_data.length)/_data._dates.length;
        String daily = dailyDouble.toStringAsFixed(2);
        if (_data._dates.length == 0){
          String string = "Please enter valid days of the week to work on the " + _taskType.toLowerCase() + ".";
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(string),
                );
              });
        }
        else {
          String str = _data._dropDownValue;
          String start = "";
          String end = " ";
          final startIndex = str.indexOf(start);
          final endIndex = str.indexOf(end, startIndex + start.length);

          _grades.addTaskData(
              _data._name,
              _data._dropDownValue,
              int.parse(_data.length),
              _data._dates,
              _data._dueDate,
              done,
              _data._forMarks,
              null,
              null,
              _taskType.toLowerCase(),
              daily,
          _data._bonus, null, (str.substring(startIndex + start.length, endIndex)));

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SchedulePage(),
              ));
        }

      } else {
        print("not valid");
      }
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(today.year, today.month, today.day),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        _data._dueDate = picked;
      });
  }

  Widget checkbox(String title, bool boolValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(title),
        Checkbox(
          activeColor: Theme.of(context).primaryColor,
          value: boolValue,
          onChanged: (bool value) {
            /// manage the state of each value
            setState(() {
              switch (title) {
                case "Mon":
                  _data._monVal = value;
                  break;
                case "Tues":
                  _data._tuVal = value;
                  break;
                case "Wed":
                  _data._wedVal = value;
                  break;
                case "Thur":
                  _data._thurVal = value;
                  break;
                case "Fri":
                  _data._friVal = value;
                  break;
                case "Sat":
                  _data._satVal = value;
                  break;
                case "Sun":
                  _data._sunVal = value;
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
        title: Text('INFORMATION FOR ' + _taskType),
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
                      labelText: _taskType[0].toUpperCase() +
                          _taskType.substring(1).toLowerCase() +
                          " name",
                    ),
                    validator: this._validateName,
                    onSaved: (String value) {
                      this._data._name = value;
                    }),
                new TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                      hintText: "Please enter " + _tasks[_index],
                      labelText: _tasks1[_index],
                    ),
                    validator: this._validateAmount,
                    onSaved: (String value) {
                      this._data.length = value;
                    }),
                new Container(
                    child: FutureBuilder(
                        future: _coursesLoaded,
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
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14 + fontScale.toDouble(),
                              ),
                              underline: Container(
                                height: 2,
                                color: Theme.of(context).primaryColor,
                              ),
                              onChanged: (String newValue) {
                                setState(() {
                                  _data.setDropDownValue(newValue);
                                });
                              },
                              items: _courseNames.map<DropdownMenuItem<String>>(
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
                          (_data._dueDate.toString() == "null"
                              ? ""
                              : _data._dueDate.day.toString().padLeft(2, "0") +
                                  "-" +
                                  _data._dueDate.month
                                      .toString()
                                      .padLeft(2, "0") +
                                  "-" +
                                  _data._dueDate.year
                                      .toString()
                                      .padLeft(2, "0")),
                    )),
                RaisedButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    'Select due date',
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 14 + fontScale.toDouble(),
                    ),
                  ),
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        checkbox("Mon", _data._monVal),
                        checkbox("Tues", _data._tuVal),
                        checkbox("Wed", _data._wedVal),
                        checkbox("Thur", _data._thurVal),
                        checkbox("Fri", _data._friVal),
                        checkbox("Sat", _data._satVal),
                        checkbox("Sun", _data._sunVal),
                      ],
                    ),
                  ],
                ),
                new Container(
                  width: screenSize.width,
                  child: new RaisedButton(
                    child: new Text(
                      'Submit',
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 14 + fontScale.toDouble(),
                      ),
                    ),
                    onPressed: this.submit,
                    color: Theme.of(context).primaryColor,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                ),
                 CheckboxListTile(
                  title: Text("Is this worth marks?"),
                  activeColor: Theme.of(context).primaryColor,
                  value: _data._forMarks,
                  onChanged: (bool value) {
                    setState(() {
                      _data._forMarks = value;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                new CheckboxListTile(
                  title: Text("Is this worth bonus marks?"),
                  value: _data._bonus,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (bool value) {
                    setState(() {
                      _data._bonus = value;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                )
              ],
            ),
          )),
    );
  }
}
