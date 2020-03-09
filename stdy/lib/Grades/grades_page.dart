import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import '../home_widget.dart';
import 'grades_data.dart';
import 'task_input_page.dart';
import 'grade_input_page.dart';
import '../main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'grade_predictor_page.dart';


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
  double totalWeights;
  String gradePred;

  Future <List<DocumentSnapshot>> _futureData;
  List<DocumentSnapshot> taskData;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

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
    totalWeights = course["totalWeight"];
    if(totalWeights==null){
      totalWeights = 0.0;
    }
    setState(() {
      if(weighted !=null) {
        letterGrade = firehouse.findLetterGPA(weighted);
      }

    });

  }

  void _calculateGrades(){

    print("calculating grade");
    double finalGrade = 0.0;
    double totalWeight = 0.0;
    double bonus = 0.0;

    for(int i =0; i<taskData.length; i++){
      DocumentSnapshot curr = taskData[i];
      print(curr["name"]);
      if(curr["grade"]==null){
        continue;
      }
      double currGrade = curr["grade"];
      int currTotal = curr["totalgrade"];
      double currWeight = curr["weight"];


      if(!curr["bonus"]){//replace this
        totalWeight+= currWeight;
        print("value is now ${curr["name"]}");
        double percentEarned = (currGrade/currTotal)*currWeight;
        finalGrade+=percentEarned;
      }
      else{
        double percentEarned = (currGrade/currTotal)*currWeight;
        bonus+=percentEarned;

      }

    }

    double weighted = double.parse(((finalGrade/totalWeight)*100+bonus).toStringAsFixed(1));
    finalGrade = double.parse((finalGrade+bonus).toStringAsFixed(1));
    //round to 2 decimals
    setState((){
      totalWeights = totalWeight;
      grade = finalGrade;
      firehouse.setCourseGrade(id, finalGrade, weighted, totalWeight);
    });
    print("weight is $totalWeights");

    firehouse.calculateGPA(null);

  }

  void _addTask() async {

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskInputPage(totalWeights),
        ));
    String type = result[0];
    String name = result[1];
    double weight = double.parse(result[2]);
    int total = int.parse(result[3]);
    double grade = double.parse(result[4]);
    bool bonus = false;
    print("bonus is ${result[5]}");
    if(result[5]=='true'){
      bonus = true;
    }

    await firehouse.addTaskData(
        name,
        id,
        0,
        null,
        null,
        null,
        true,
        weight,
        grade,
        type,
        null,
        bonus,
        total,
        id

    );

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
          title: new Text("Confirm",
            style: TextStyle(
              fontSize: 16.0 + fontScale,
            ),),
          content: new Text("Are you sure you want to delete task $task?",
            style: TextStyle(
              fontSize: 16.0 + fontScale,
            ),),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes",
                style: TextStyle(
                  fontSize: 16.0 + fontScale,
                ),),
              onPressed: () async{
                print("removed coure");
                await firehouse.remove_task(task, id);
                await _getData();
                _calculateGrades();
                setState(() {_getData();});

                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("No",
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

  void _openTaskPage(Map<String, dynamic> task) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskInfoPage(task),
        ));
    setState(() {});
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

        double percent = tasks[i]["grade"] / tasks[i]["totalgrade"];
        double gradeWeighted =  percent* tasks[i]["weight"];
        gradeWeighted = double.parse(gradeWeighted.toStringAsFixed(1));
        percent = double.parse((percent*100).toStringAsFixed(1));

        gradeInfo = 'Earned: ${tasks[i]["grade"]}/${tasks[i]["totalgrade"]}     Weighted: $gradeWeighted/${tasks[i]["weight"]}';
        title += " ($percent%)";
      }

      courseWidgets.add(
        ListTile(
            title: Text(title,
              style: TextStyle(
                fontSize: 16.0 + fontScale,
              ),),
            subtitle: Text(gradeInfo,
              style: TextStyle(
                fontSize: 16.0 + fontScale,
              ),),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Increase volume by 10',
              onPressed: () {
                _removeData(tasks[i]["id"]);
              },
            ),
            onTap: () {
              setState(() {
                _openTaskPage(tasks[i]);
              });
            }),


      );
    }

    return courseWidgets;

  }
  void _openGradePredictor() async{

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GradePredictorPage(course),
        ));
r

  }

  String _validateGradePredict(String value) {
    if (value.isEmpty) return 'Please enter a valid grade.';
    return null;
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
              title: Text("${item.headerValue}s",
                style: TextStyle(
                  fontSize: 16.0 + fontScale,
                ),),
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
          title: Text('$courseName $sem',
            )
      ),


      floatingActionButton: SpeedDial(
        child: Icon(Icons.open_in_new),
        overlayOpacity: 0.0,
        children: [

          SpeedDialChild(
              child: Icon(Icons.add),
              backgroundColor: stdyPink,
              labelBackgroundColor: stdyPink,
              shape: CircleBorder(),
              label: 'New Task',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => _addTask(),
          ),
          SpeedDialChild(
            child: Icon(Icons.grade),
            backgroundColor: stdyPink,
            labelBackgroundColor: stdyPink,
            label: 'Predictor',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _openGradePredictor(),
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
                          fontSize: 16.0 + fontScale,
                        ),
                      ),
                      Text("Total weight: $totalWeights",
                        style: TextStyle(
                          fontSize: 16.0 + fontScale,
                        ),),
                      Text("Actual grade: $grade%",
                        style: TextStyle(
                          fontSize: 16.0 + fontScale,
                        ),),
                      Text("Current grade: $weighted%",
                        style: TextStyle(
                          fontSize: 16.0 + fontScale,
                        ),),
                      Text("Letter grade: $letterGrade",
                        style: TextStyle(
                          fontSize: 16.0 + fontScale,
                        ),),

                    ]
                )
            ),
            Container(child: projectWidget()),
            /*
            SizedBox(height: 30),
            _buildForm(context),
            Text("mark needed is %$gradePred"),*/
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

