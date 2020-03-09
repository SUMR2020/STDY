import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:googleapis/cloudbuild/v1.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import '../Schedule/TaskData.dart';
import 'package:study/Grades/Model/CourseData.dart';

class GradePredictorPage extends StatefulWidget {

  Map<String, dynamic> course;
  GradePredictorPage(this.course);

  @override
  State<StatefulWidget> createState() {
    return GradePredictorState(this.course);
  }
}

class GradePredictorState extends State<GradePredictorPage> {

  Map<String, dynamic> course;
  String courseName;
  String sem;
  String id;
  CourseData firehouse;


  GradePredictorState( Map<String, dynamic> c){
    course = c;

    firehouse = new CourseData();

    courseName = course["id"];
    sem = course["semester"]+course["year"].toString();

  }

  @override
  Widget build(BuildContext context) {
    print("building course");
    return Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text('$courseName $sem Predictor',
          )
      ),

      body: SingleChildScrollView(

        child: Column(
          children: <Widget>[
            ]

        ),

      ),
    );
  }

}

