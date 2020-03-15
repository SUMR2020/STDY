import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../Input/PrevTaskFormPage.dart';
import '../../../UpdateApp/Subject/Theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'TaskPage.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../Predictor/GradePredictorPage.dart';
import 'package:study/GoogleAPI/Firestore/GradesFirestore.dart';
import '../../Subject/GradesData.dart';
import '../../Helper/Course.dart';
import '../../Helper/TaskItem.dart';
import '../../../Schedule/Helper/Task.dart';


class CoursePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return CoursePageState();
  }
}

class CoursePageState extends State<CoursePage> {

  GradesData gradesData;

  String gradePred;
  Future <bool> _futureData;
  List<DocumentSnapshot> taskData;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  CoursePageState(){
    gradesData = GradesData();
    _futureData = gradesData.fetchTaskObjects();
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
    /*
    setState((){
      totalWeights = totalWeight;
      grade = finalGrade;
      firehouse.setCourseGrade(id, finalGrade, weighted, totalWeight);
    });
    print("weight is $totalWeights");

     */

    //firehouse.calculateGPA(null);

  }

  void _addTask() async {

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrevTaskFormPage(),
        ));
    print("hello thisting completed");

    setState(() {});

  }


  void _removeData(Task task) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm",
            style: TextStyle(
              fontSize: 16.0 + fontScale,
            ),),
          content: new Text("Are you sure you want to delete task ${task.name}?",
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
                await gradesData.removeTaskData(task.id);

                setState(() {});

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


  void _openTaskPage(String id) async {
    GradesData.currTaskID = id;
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskPage(),
        ));
    setState(() {});
  }

  List<Widget> _buildTasks(String type, List<Task> tasks){
    List<Widget> courseWidgets = <Widget>[];

    print("building task for $type");
    for(int i =0; i<tasks.length; i++){
      //String grade = firehouse.getCourseGrade((tasks[i]+semester).replaceAll(' ',''));
      //print(grade);

      String gradeInfo;
      String title = tasks[i].name;
      print("course title is $title");
      String dueDate = "Due: ";
      if(tasks[i].grade==null){
        gradeInfo = "Click to add grade";
      }

      else {

        double percent = tasks[i].grade / tasks[i].totalGrade;
        double gradeWeighted =  percent* tasks[i].weight;
        gradeWeighted = double.parse(gradeWeighted.toStringAsFixed(1));
        percent = double.parse((percent*100).toStringAsFixed(1));

        gradeInfo = 'Earned: ${tasks[i].grade}/${tasks[i].totalGrade}     Weighted: $gradeWeighted/${tasks[i].weight}';
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
              onPressed: () {
                _removeData(tasks[i]);
              },
            ),
            onTap: () {
              setState(() {
                _openTaskPage(tasks[i].id);
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
          builder: (context) => GradePredictorPage(),
        ));
  }

  Widget _buildPanel()  {

    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {

          GradesData.taskItems[index].isExpanded = !isExpanded;
        });
      },
      children: GradesData.taskItems.map<ExpansionPanel>((TaskItem item) {
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

  Widget buildUserInfo(){
    return Container(
        child: Container(
            child: Column(
                children: <Widget>[
                  Text("Student Stats",
                    style: TextStyle(
                      fontSize: 16.0 + fontScale,
                    ),
                  ),
                  Text("Total weight: ${gradesData.totalWeights}",
                    style: TextStyle(
                      fontSize: 16.0 + fontScale,
                    ),),
                  Text("Actual grade:${gradesData.grade}%",
                    style: TextStyle(
                      fontSize: 16.0 + fontScale,
                    ),),
                  Text("Current grade: ${gradesData.weighted}%",
                    style: TextStyle(
                      fontSize: 16.0 + fontScale,
                    ),),
                  Text("Letter grade: ${gradesData.letterGrade}",
                    style: TextStyle(
                      fontSize: 16.0 + fontScale,
                    ),),

                ]
            )
        )
    );
  }

  Widget projectWidget() {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (!projectSnap.hasData) {
          return Container(
              alignment: Alignment.center,
              child: SizedBox(
                  height: 100,
                  width: 100,
                  child:  CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  )
              )
          );
        }
        else {
          return Column(
            children: <Widget>[
              buildUserInfo(),
              _buildPanel(),
            ],
          );
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
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColor, //change your color here
          ),
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text(''
              '${gradesData.getCourseByID(GradesData.currCourseID).code} '
              '${gradesData.getCourseByID(GradesData.currCourseID).sem} '
              '${gradesData.getCourseByID(GradesData.currCourseID).year}',
            )
      ),


      floatingActionButton: SpeedDial(
        child: Icon(Icons.open_in_new),
        overlayOpacity: 0.0,
        children: [

          SpeedDialChild(
              child: Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
              labelBackgroundColor: Theme.of(context).primaryColor,
              shape: CircleBorder(),
              label: 'New Task',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => _addTask(),
          ),
          SpeedDialChild(
            child: Icon(Icons.grade),
            backgroundColor: Theme.of(context).primaryColor,
            labelBackgroundColor: Theme.of(context).primaryColor,
            label: 'Predictor',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _openGradePredictor(),
          ),

        ],

      ),

      body: SingleChildScrollView(
        child: projectWidget(),
      ),
    );
  }
}



