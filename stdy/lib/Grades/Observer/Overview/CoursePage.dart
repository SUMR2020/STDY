import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../Input/PrevTaskFormPage.dart';
import '../../../UpdateApp/Subject/SettingsData.dart';
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
  //List<DocumentSnapshot> taskData;

  CoursePageState(){
    gradesData = GradesData();
    _futureData = gradesData.fetchTaskObjects();
  }



  void _addTask() async {

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrevTaskFormPage(),
        ));
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

    for(int i =0; i<tasks.length; i++){
      //String grade = firehouse.getCourseGrade((tasks[i]+semester).replaceAll(' ',''));
      //print(grade);

      String earnedInfo, weightedInfo;
      double percent;
      String dueDate = "Due: ";
      if(tasks[i].grade==null){
        earnedInfo = "";
        weightedInfo = "";

      }

      else {

        percent = tasks[i].grade / tasks[i].totalGrade;
        double gradeWeighted =  percent* tasks[i].weight;
        gradeWeighted = double.parse(gradeWeighted.toStringAsFixed(1));
        percent = double.parse((percent*100).toStringAsFixed(1));

        earnedInfo = 'Earned: ${tasks[i].grade}/${tasks[i].totalGrade}';
        weightedInfo ='$gradeWeighted/${tasks[i].weight}';

      }

      courseWidgets.add(
          GestureDetector(
              onTap: () {
                _openTaskPage(tasks[i].id);
                setState(() {});
              },
              child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.15,
                    height: 70 ,
                    child: DecoratedBox(

                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 10.0,top: 10.0),
                                child: Text(tasks[i].name,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Text(earnedInfo,
                                  style: TextStyle(
                                      fontSize: 14.0+fontScale,
                                      color: Colors.white,
                                  ),),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Text(weightedInfo,
                                  style: TextStyle(
                                    fontSize: 14.0+fontScale,
                                    color: Colors.white,
                                  ),),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text("$percent%",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),),
                          ),

                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.white,
                            tooltip: 'Increase volume by 10',
                            onPressed: () {
                              _removeData(tasks[i]);
                            },
                          ),
                        ],
                      ),


                    ),

                  )
              )
          )
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
    double progressValue = gradesData.getCourseByID(GradesData.currCourseID).totalWeight/100;

    return Padding(
        padding: EdgeInsets.all(10.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.1,
          height: 180 ,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("STATS",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text("Completed",
                        style: TextStyle(
                            fontSize: 16.0+fontScale,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),),
                    ),
                    SizedBox(
                      width: 200,
                      child:LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: Colors.white,
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text("${gradesData.getCourseByID(GradesData.currCourseID).totalWeight}%",
                        style: TextStyle(
                            fontSize: 16.0+fontScale,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),),
                    ),
                  ],
                ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    statsColumn("Weighted Grade", gradesData.getCourseByID(GradesData.currCourseID).weighted.toString()),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(gradesData.getCourseByID(GradesData.currCourseID).letterGrade,
                        style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),),
                    ),
                    statsColumn("Actual Grade", gradesData.getCourseByID(GradesData.currCourseID).grade!=-1.0? gradesData.getCourseByID(GradesData.currCourseID).grade.toString():"N/A"),
                  ],
                )
              ],
            ),
          ),
        )
    );
  }

  Widget statsColumn(String title, String text){

    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text(title,
              style: TextStyle(
                fontSize: 16.0+fontScale,
                color: Colors.white,
              ),),
            Text(text!='null'?text:"N/A",
              style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),),
          ],
        )
    );
  }


  /*

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
  }*/

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



