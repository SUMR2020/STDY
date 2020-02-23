import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class CourseData{
}

class TaskData{
}

class GradeData {

  TextEditingController _txtCtrl = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final db = Firestore.instance;

  List<String> grades = ["F", "D-", "D", "D+","C-", "C", "C+","B-", "B", "B+","A-", "A", "A+"];
  List<DocumentSnapshot> currDocuments;
  String university= "Carleton";
  Map<String, dynamic> letterGPA;

  GradesData(){
    print("started grades");
  }


  double getGPA(bool curr){
    double gpa = 0.0;
    int size = currDocuments.length;

    for(int i =0; i<currDocuments.length; i++) {
      Map<String, dynamic> doc = currDocuments[i].data;

      if(doc["taken"]=="CURR"){
        if(curr && doc.containsKey("weighted")){
          gpa += double.parse(findNumberGPA(doc["weighted"]));
        }
        else{
          size--;
        }
      }

      gpa += double.parse(findNumberGPA(doc["grade"]));
    }
    return gpa/size;
  }

  String findNumberGPA(double grade){
    if(letterGPA==null) {
      print("letterGPA is $letterGPA");
    }

    print("test for ${letterGPA[0]}");

    //List<String> letters = letterGPA.keys.toList()..sort();
    List<String> letters = new List();
    letterGPA.forEach((k, v) => letters.add(k));
    letters.sort();

    String curr=letters[0];
    for(int i =0; i<letters.length; i++){
      String key = letters[i];

      if(letterGPA[key]>grade){
        break;
      }
      curr = letters[i];

    }
    print("returning value grade of $curr");

    return curr;
  }
  String findLetterGPA(double grade){
    String numberGPA = findNumberGPA(grade);
    return grades[int.parse(numberGPA)];
  }

  String getCourseGrade(String course){

    for(int i =0; i<currDocuments.length; i++) {


      if (currDocuments[i].documentID==course) {

        if(currDocuments[i].data["taken"]=="CURR"){

          if(currDocuments[i].data.containsKey("weighted")){
            double grade = currDocuments[i].data["weighted"];
            String numberGPA = findNumberGPA(grade);
            return "CURR (${grades[int.parse(numberGPA)]})";
          }
          else{
            return "CURR";
          }

        }
        else{
          double grade = currDocuments[i].data["grade"];
          String numberGPA = findNumberGPA(grade);
          return grades[int.parse(numberGPA)];
        }

      }

    }
    return "N/A";
  }

  Future <Map<String, dynamic> > getCourse(String id) async{
    List<DocumentSnapshot> list = await getCourseData();
    for (int i=0; i<list.length; i++){
      if(list[i].documentID==id){
        return list[i].data;
      }
    }


  }

  String calculateSemGPA(String sem, int size) {
    double gpa=0.0;

    List<String> letters = new List();

    //print("calcsemGPA got data from $letterGPA");
    letterGPA.forEach((k, v) => letters.add(k));
    letters.sort();
    //print("letters are $letters");

    for(int i =0; i<currDocuments.length; i++) {

      String temp =  currDocuments[i].data["semester"]+" "+currDocuments[i].data["year"].toString();

      if (temp==sem) {
        if(currDocuments[i].data["taken"]=="CURR"){
          size--;
        }
        else {
          gpa += double.parse(findNumberGPA(currDocuments[i].data["grade"]));
        }
      }

    }
    gpa = gpa/size;

    if(gpa.isNaN){
      print("gpa is nana $gpa");


      return "CURR";
    }

    return gpa.toStringAsFixed(2);

  }

  void testing() async{

    // here you write the codes to input the data into firestore
  }

  void remove_course(String id) async{
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    db.collection("users").document(uid).collection("Grades").document(id).delete();
    print("removed $id");

  }

  void remove_task(String id, String course) async{
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    db.collection("users").document(uid).collection("Grades").document(course).collection("Tasks").document(id).delete();
    print("removed $id");

  }


  void addData(List<String> data) async {

    if(data==null){
      return;
    }
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    bool exists=true;
    String course = data[0];
    String semester = data[1];
    int year = int.parse(data[2]);
    String currCourse;

    double grade = 0.0;
    if(data[3]=="CURR") {
      currCourse = "CURR";
    }
    else{
      grade = double.parse(data[3]);
      currCourse = "PAST";

    }

    String id = (data[0]+data[1]+data[2]).replaceAll(' ','');

    await db.collection("users").document(uid).get().then((DocumentSnapshot data) {
      exists = data.exists;

    });

    if(!exists) {
      await db.collection("users").document(uid).setData({"gpa": -1});
    }
    await db.collection("users").document(uid).collection("Grades").document(id).setData(
        {"id": course,"year": year, "grade": grade,"semester": semester, "taken": currCourse}
    );

    print("added data to $uid");
  }


  void addTaskGrade(String name, String course, List<String> gradeInput) async {
    print("adding $name to $course");

    double weight = double.parse(gradeInput[0]);
    double total = double.parse(gradeInput[1]);
    double grade = double.parse(gradeInput[2]);


    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    course = course.replaceAll(" ", "");
    await db.collection("users").document(uid).collection("Grades").document((course)).collection("Tasks").document(name).updateData(
        {"weight": weight, "total": total, "grade": grade});

    print("added data to $uid");
  }

  void addPastTaskData(String course, List<String> data)async {

    String type = data[0];
    String name = data[1];
    double weight = double.parse(data[2]);
    double total = double.parse(data[3]);
    double grade = double.parse(data[4]);

    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    await db.collection("users").document(uid).collection("Grades").document((course)).collection("Tasks").document(name).setData(

        {"curr": false, "name": name,"course": course, "weight": weight, "grade": grade, "type": type, "total": total}
    );

  }

  void addTaskData(String name, String course, int toDo, List<DateTime> dates, DateTime dueDate, List<int> done, bool forMarks, double weight, double grade, String type, String daily) async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    String id = (new DateTime.now().millisecondsSinceEpoch).toString();
    course = course.replaceAll(" ", "");
    await db.collection("users").document(uid).collection("Grades").document((course)).collection("Tasks").document(id).setData(
        {"id": id, "name": name,"course": course, "toDo": toDo,"dates": dates, "due": dueDate, "progress": done, "forMarks": forMarks, "weight": weight, "grade": grade, "type": type, "daily": daily, "curr": true}

    );

//    if (forMarks) {
//      print ("in for");
//      var tasks = {name : -1};
//      course = course.replaceAll(" ", "");
//
//      DocumentReference docRef = db.collection("users").document(uid).collection("Grades").document(course);
//      docRef.setData({"tasks": tasks}, merge: true);
//    }

    print("added data to $uid");
  }
//Future <Map<String, int>>
  void getGPATable() async {


    final QuerySnapshot result =
    await db.collection('gpa').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    for(int i =0; i<documents.length; i++){
      if(documents[i].documentID==university){
        print("Assigned letter gpa!");
        letterGPA = documents[i].data;
      }
    }

  }

  Future <bool> updateProgressandDaily(String id, String course, String done) async{
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    DocumentReference docRef = db.collection("users").document(uid).collection("Grades").document(course).collection("Tasks").document(id);
    var before = await docRef.get();
    int totalBefore = before["toDo"];
    double totalAfter = ((totalBefore)-double.parse(done));
    if (totalAfter<0) totalAfter = 0;
    var days = before["dates"];
    var progress = before["progress"];
    if (progress == null) progress = new List<String>();
    progress.add(done);
    docRef.updateData({"progress": progress});
    docRef.updateData({"toDo": totalAfter});
    docRef.updateData({"daily": (totalAfter/days.length).toString()});
    return true;
  }

  Future <List<DocumentSnapshot>> getCourseData() async {
    if(letterGPA==null) {
      //print("letter is null");
      getGPATable();
    }
    else{
      //print("letter isnt");
    }


    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    final QuerySnapshot result =
    await db.collection('users').document(uid).collection("Grades").getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    //documents.forEach((data) => print(data.data));
    currDocuments = documents;
    return documents;

  }

  Future <List<DocumentSnapshot>> getTasksData(String course) async {

    if(letterGPA==null) {
      //print("letter is null");
      getGPATable();
    }
    else{
      //print("letter isnt");
    }

    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    final QuerySnapshot result =
    await db.collection('users').document(uid).collection("Grades").document(course).collection("Tasks").getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    //documents.forEach((data) => print(data.data));
    currDocuments = documents;

    return documents;

  }

  void setCourseGrade(String course, double grade, double weighted) async{
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    course = course.replaceAll(" ", "");

    await db.collection("users").document(uid).collection("Grades").document((course)).updateData(
        {"grade": grade,"weighted": weighted});

  }

  Map<String, List<Map<String, dynamic>>> getTasksByType(List<DocumentSnapshot> documents){

    /*

    documents.sort((a,b) {
      String aSem = a.data["semester"];
      String bSem = b.data["semester"];
      var aYear = a.data["year"];
      var bYear = b.data["year"];
      int val = bYear-aYear;
      print("hello?");

      if(val==0){
        return aSem.compareTo(bSem);
      }
      return val;

    });*/

    Map<String, List<Map<String, dynamic>>> mapData = Map();

    for(int i =0; i<documents.length; i++) {
      String type = documents[i].data["type"];
      if (!mapData.containsKey(type)) {
        mapData[type] = <Map<String, dynamic>>[];

      }
      mapData[type].add(documents[i].data);

    }

    return mapData;
  }


  Map<String, List<Map<String, dynamic>>> getCourseNameSem(List<DocumentSnapshot> documents){

    documents.sort((a,b) {
      String aSem = a.data["semester"];
      String bSem = b.data["semester"];
      var aYear = a.data["year"];
      var bYear = b.data["year"];
      int val = bYear-aYear;
 ;

      if(val==0){
        return aSem.compareTo(bSem);
      }
      return val;

    });

    Map<String, List<Map<String, dynamic>>> mapData = Map();

    for(int i =0; i<documents.length; i++) {

      String sem =  documents[i].data["semester"]+" "+documents[i].data["year"].toString();

      if (!mapData.containsKey(sem)) {
        mapData[sem] = <Map<String, dynamic>>[];

      }

      mapData[sem].add(documents[i].data);

    }

    return mapData;
  }
  Future <List<DocumentSnapshot>> getTasks() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    List<DocumentSnapshot> allTasks = new List<DocumentSnapshot>();
    List<DocumentSnapshot> courses = await getCourseData();
    for (DocumentSnapshot course in courses){
      String name = course.data["id"] + course.data["semester"] + course.data["year"].toString();
      final QuerySnapshot courseTasks =
      await db.collection('users').document(uid).collection("Grades").document(name).collection("Tasks").getDocuments();
      final List<DocumentSnapshot> documents = courseTasks.documents;
      documents.forEach((data) => allTasks.add(data));
    }
    return allTasks;
  }
}


