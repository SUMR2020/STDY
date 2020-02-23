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

  Map<String, dynamic> course;
  GradesPage(this.course);

  @override
  State<StatefulWidget> createState() {
    return GradesPageState(this.course);
  }
}

class GradesPageState extends State<GradesPage> {

  Map<String, dynamic> course;
  String courseName;

  String sem;
  String id;
  GradeData firehouse;
  double grade;
  double weighted;
  String letterGrade;
  Future <List<DocumentSnapshot>> _futureData;
  List<DocumentSnapshot> taskData;

  List<Item> _data;

  GradesPageState(Map<String, dynamic> c){
    firehouse = new GradeData();

    course = c;
    courseName = course["id"];
    sem = course["semester"]+course["year"].toString();
    grade = course["grade"];
    weighted = course["weighted"];

    print("opened $courseName $sem screen");
    id = (courseName + sem).replaceAll(' ', '');

    _futureData = _getData();

  }

  void _getCourse() async {
    course = await firehouse.getCourse(id);
    grade = course["grade"];
    weighted = course["weighted"];
    setState(() {
      letterGrade = firehouse.findLetterGPA(weighted);

    });

  }

  void _calculateGrades(){

    print("calculating grade");
    double finalGrade = 0.0;
    double totalWeight = 0.0;

    for(int i =0; i<taskData.length; i++){
      DocumentSnapshot curr = taskData[i];

      if(curr["grade"]==null){
        continue;
      }

      double currGrade = curr["grade"];
      double currTotal = curr["total"];
      double currWeight = curr["weight"];
      totalWeight+= currWeight;

      double percentEarned = (currGrade/currTotal)*currWeight;
      finalGrade+=percentEarned;
      //print("$i: grade= $currGrade, weight: $currWeight, total: $currTotal for a total of $percentEarned");

    }


    double weighted = double.parse(((finalGrade/totalWeight)*100).toStringAsFixed(1));
    finalGrade = double.parse(finalGrade.toStringAsFixed(1));
    //round to 2 decimals
    setState((){
      grade = finalGrade;
      firehouse.setCourseGrade(id, finalGrade, weighted);
    });

  }



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
    _calculateGrades();
    //setState(() {});

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
    _calculateGrades();
    //setState(() {});

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
                print("removed coure");
                await firehouse.remove_task(task, id);
                await _getData();
                _calculateGrades();
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

    //print("in genItems");
    List<String> sortedKeys = data.keys.toList();
    //print("converted to sortkeys");

    sortedKeys.forEach((key) =>
        items.add(
            Item(
                headerValue: key.toString(),
                expandedValue: "This is a value thing",
                expandedText: data[key],
            )
        )
    );
    //print("and done");



    return items;
  }

  Future <List<DocumentSnapshot>> _getData() async {

    taskData =  await firehouse.getTasksData(id);
    print("got the data");
    Map<String, List<Map<String, dynamic>>> tasksByType = firehouse.getTasksByType(taskData);

    //print("converted data to map");
    _data = generateItems(tasksByType);

    _getCourse();

    return taskData;

  }


  List<Widget> _buildTasks(String type, List<Map<String, dynamic>> tasks){
    List<Widget> courseWidgets = <Widget>[];

    print("building task for $type");
    for(int i =0; i<tasks.length; i++){
      //String grade = firehouse.getCourseGrade((tasks[i]+semester).replaceAll(' ',''));
      //print(grade);

      String gradeInfo;
      String title = tasks[i]["name"];
      String dueDate = "Due: ";
      if(tasks[i]["grade"]==null){
        gradeInfo = "Click to add grade";
      }

      else {

        double percent = tasks[i]["grade"] / tasks[i]["total"];
        double gradeWeighted =  percent* tasks[i]["weight"];
        gradeWeighted = double.parse(gradeWeighted.toStringAsFixed(1));
        percent = double.parse((percent*100).toStringAsFixed(1));

        gradeInfo = 'Earned: ${tasks[i]["grade"]}/${tasks[i]["total"]}     Weighted: $gradeWeighted/${tasks[i]["weight"]}';
        title += " ($percent%)";
      }

      courseWidgets.add(
        ListTile(
            title: Text(title),
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
    print("building course");
    return Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text('$courseName $sem')
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
                      Text("Actual grade: $grade%"),
                      Text("Current grade: $weighted%"),
                      Text("Letter grade: $letterGrade")

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

