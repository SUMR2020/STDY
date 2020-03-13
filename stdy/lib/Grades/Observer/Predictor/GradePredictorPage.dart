import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:study/GoogleAPI/Firestore/GradesFirestore.dart';

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
  GradesFirestore firehouse;


  GradePredictorState( Map<String, dynamic> c){
    course = c;

    firehouse = new GradesFirestore();

    courseName = course["id"];
    sem = course["semester"]+course["year"].toString();

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

