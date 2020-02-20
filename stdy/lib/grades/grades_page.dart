import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import '../home_widget.dart';
import 'grades_data.dart';
import 'task_input_page.dart';
import 'grade_input_page.dart';
import '../main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GradesPage extends StatefulWidget {
  String course;
  String sem;
  GradesPage(this.course, this.sem);

  @override
  State<StatefulWidget> createState() {
    return GradesPageState(this.course, this.sem);
  }
}

class GradesPageState extends State<GradesPage> {

  int marks;
  String _finalGradeText;
  String course;
  String sem;
  String id;
  GradeData firehouse;
  double grade;
  Future <List<DocumentSnapshot>> _futureData;
  List<DocumentSnapshot> taskData;

  List<Item> _data;

  //String get grade => _grade.text;
  static List<Widget> _children;

  GradesPageState(String c, String s){
    firehouse = new GradeData();

    course = c;
    sem = s;
    id = (course + sem).replaceAll(' ', '');

    print("opened $course screen");
    _finalGradeText = '';
    marks = 0;

    _children = [];
    grade = 0;

    _futureData = _getData();
  }

  /*
  void _calculateGrades(){

    double finalGrade = 0.0;

    for(int i =0; i<marks; i++){

      if(_grade[i].text=='' || _weight[i].text=='' || _total[i].text=='')
        return;

      double currGrade = double.parse(_grade[i].text);
      double currTotal = double.parse(_total[i].text);
      double currWeight = double.parse(_weight[i].text);
      double percentEarned = (currGrade/currTotal)*currWeight;
      finalGrade+=percentEarned;
      print("$i: grade= $currGrade, weight: $currWeight, total: $currTotal for a total of $percentEarned");


    }
    //round to 2 decimals

    setState((){
      _finalGradeText = finalGrade.toStringAsFixed(2);
    });


  }
*/


  void _addTask() async {

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskInputPage(),
        ));

    //await firehouse.addData(result);
    //await firehouse.addTaskData(_data.name, _data.dropDownValue, int.parse(_data.length), _data.dates, _data.dueDate, done, _data.forMarks, null, null, null,taskType.toLowerCase());
    await firehouse.addPastTaskData(id, result);
    //await _getData();
    print(result);

    await _getData();
    setState(() {});

  }

  void _addGrade(String task, String type) async {
    print("Grade added");

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GradeInputPage(),
        ));
    print(result);
    await firehouse.addTaskGrade(task, id, result);

    await _getData();
    setState(() {});

  }

  void _removeData(String task) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm"),
          content: new Text("Are you sure you want to delete task $task?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () async{
                await firehouse.remove_task(task, id);
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

  List<Item> generateItems(Map<String, List<Map<String, dynamic>>> data) {
    List<Item> items = <Item>[];

    print("in genItems");
    List<String> sortedKeys = data.keys.toList();
    print("converted to sortkeys");

    sortedKeys.forEach((key) =>
        items.add(
            Item(
                headerValue: key.toString(),
                expandedValue: "This is a value thing",
                expandedText: data[key],
            )
        )
    );
    print("and done");



    return items;
  }

  Future <List<DocumentSnapshot>> _getData() async {

    taskData =  await firehouse.getTasksData(id);
    print("got the data");
    Map<String, List<Map<String, dynamic>>> tasksByType = firehouse.getTasksByType(taskData);

    print("converted data to map");
    _data = generateItems(tasksByType);


    return taskData;

  }


  List<Widget> _buildTasks(String type, List<Map<String, dynamic>> tasks){
    List<Widget> courseWidgets = <Widget>[];

    print("building task for $type");
    for(int i =0; i<tasks.length; i++){
      //String grade = firehouse.getCourseGrade((tasks[i]+semester).replaceAll(' ',''));
      //print(grade);

      String gradeInfo;
      if(tasks[i]["grade"]==null){
        gradeInfo = "Click to add grade";
      }

      else {
        double percent = tasks[i]["grade"] / tasks[i]["total"] *
            tasks[i]["weight"];
        gradeInfo = 'Earned: ${tasks[i]["grade"]}/${tasks[i]["total"]}     Percent: $percent/${tasks[i]["weight"]}%';
      }

      courseWidgets.add(
        ListTile(
            title: Text(tasks[i]["name"]),
            subtitle: Text(gradeInfo),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Increase volume by 10',
              onPressed: () {
                _removeData(tasks[i]["name"]);
              },
            ),
            onTap: () {
              setState(() {
                if(tasks[i]["grade"]==null){
                  _addGrade(tasks[i]["name"], tasks[i]["type"]);
                }
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
              title: Text("${item.headerValue}s"),
            );
          },
          body: Container(
              child: Column(
                  children: _buildTasks(item.headerValue, item.expandedText)
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
    print('in build$_finalGradeText');
    return Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text('$course $sem')
      ),

      body: SingleChildScrollView(

        child: Column(
          children: <Widget>[

            RaisedButton(
              child: Text('Add new task'),
              onPressed: (){
                _addTask();
              },
            ),
            Container(
                child: Column(
                    children: <Widget>[
                      Text("Student Stats"),
                      Text("grade: $grade"),

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
  });

  String expandedValue;
  String headerValue;
  List<Map<String, dynamic>> expandedText;
  bool isExpanded;
}

