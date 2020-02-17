import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';


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

  double getGPA(){
    double gpa = 0.0;
    int size = currDocuments.length;

    for(int i =0; i<currDocuments.length; i++) {

      if(currDocuments[i].data["taken"]=="CURR"){
        size--;
      }
      else{
        gpa+= double.parse(findLetterGPA(currDocuments[i].data["grade"]));

      }
    }
    return gpa/size;


  }
  String findLetterGPA(double grade){

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

    return curr;

  }

  String getCourseGrade(String course){


    for(int i =0; i<currDocuments.length; i++) {

      if (currDocuments[i].documentID==course) {
        if(currDocuments[i].data["taken"]=="CURR"){
          return "CURR";
        }

        double grade = currDocuments[i].data["grade"];
        String numberGPA = findLetterGPA(grade);

        return grades[int.parse(numberGPA)];

      }

    }
    return 'N/A';
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
          gpa += double.parse(findLetterGPA(currDocuments[i].data["grade"]));
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

  void remove_data(String id) async{
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    db.collection("users").document(uid).collection("Grades").document(id).delete();
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

  void addTaskData(String name, String course, int toDo, List<DateTime> dates, DateTime dueDate, List<int> done, bool forMarks, double weight, double grade, String type) async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    course = course.replaceAll(" ", "");
    await db.collection("users").document(uid).collection("Grades").document((course)).collection("Tasks").document(name).setData(
        {"name": name,"course": course, "toDo": toDo,"dates": dates, "due": dueDate, "progress": done, "forMarks": forMarks, "weight": weight, "grade": grade, "type": type}
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
        print("We good!");
        letterGPA = documents[i].data;
      }
    }

  }

  Future <List<DocumentSnapshot>> getCourseData() async {
    if(letterGPA==null) {
      print("letter is null");
      getGPATable();
    }
    else{
      print("letter isnt");
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


  Map<String, List<String>> getCourseNameSem(List<DocumentSnapshot> documents){

    print("we about to sort");



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

    });



    print("we just sorted");

    Map<String, List<String>> mapData = Map();

    for(int i =0; i<documents.length; i++) {
      print(documents[i].documentID);
      String sem =  documents[i].data["semester"]+" "+documents[i].data["year"].toString();

      if (!mapData.containsKey(sem)) {
        mapData[sem] = <String>[];

      }

      mapData[sem].add(documents[i].data["id"]);

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
