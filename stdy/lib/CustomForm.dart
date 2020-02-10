import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:study/main.dart';
import 'package:validate/validate.dart';

class LoginPage extends StatefulWidget {
  String taskType;
  int index;
  LoginPage(String t, int i) {
    taskType = t;
    index = i;
  }
  @override
  State<StatefulWidget> createState() => new _LoginPageState(taskType, index);
}

class _Data {
  String name = '';
  String length = '';
  DateTime dueDate;
  List<DateTime> dates;
}

class _LoginPageState extends State<LoginPage> {
  String taskType;
  int index ;
  List<String> tasks = ["pages of reading.", "estimated time to spend on the assignment.", "estimated time to spend on the project.",
    "amount of time to spend on lectures.", "amount of time to spend writing notes."];

  List<String> tasks1 = ["Amount of pages", "Estimated time", "Estimated time",
    "Amount of time", "Estimated time"];

  _LoginPageState(String t, int i) {
    taskType = t;
    index = i;
  }

  bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
  bool isNullEmptyFalseOrZero(Object o) =>
      o == null || false == o || 0 == o || "" == o;

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
    if (!isNumeric(value))
      return 'Please enter a valid number.';
    return null;
  }

  void submit() {
    // First validate form.
    if (this._formKey.currentState.validate() &&(!isNullEmptyFalseOrZero(_data.dueDate))) {
      _formKey.currentState.save(); // Save our form now.
      print('Printing the login data.');
      print('Email: ${_data.name}');
      print('Password: ${_data.length}');
    }
    else{
      print ("not valid");
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
        print (picked);
        _data.dueDate = picked;
      });
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
                        labelText: taskType[0].toUpperCase()+ taskType.substring(1).toLowerCase() + " name",
                    ),
                    validator: this._validateName,
                    onSaved: (String value) {
                      this._data.name = value;
                    }
                ),
                new TextFormField(

                    decoration: new InputDecoration(
                        hintText: "Please enter " + tasks[index],
                        labelText: tasks1[index],
                    ),
                    validator: this._validateAmount,
                    onSaved: (String value) {
                      this._data.length = value;
                    }
                ),
                RaisedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select due date'),
                ),
                new Container(
                  width: screenSize.width,
                  child: new RaisedButton(
                    child: new Text(
                      'Submit',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    ),
                    onPressed: this.submit,
                    color: stdyPink,
                  ),
                  margin: new EdgeInsets.only(
                      top: 20.0
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}