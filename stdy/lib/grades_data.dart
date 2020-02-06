import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';


class GradeData {

  TextEditingController _txtCtrl = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final db = Firestore.instance;

  GradesData(){



    print("started grades");

  }


  void testing() async{

      // here you write the codes to input the data into firestore
  }


  void addData(String course, int year) async {

    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    bool exists=true;

    await db.collection("users").document(uid).get().then((DocumentSnapshot data) {
      exists = data.exists;

    });

    if(exists){
      await db.collection("users").document(uid).collection("Grades").document(course).setData({"id": course, "year": year, "grade": -1});
    }

    else{
      await db.collection("users").document(uid).setData({"gpa": -1});
      await db.collection("users").document(uid).collection("Grades").document(course).setData({"id": course,"year": year, "grade": -1});

    }

    print("added data to $uid");

  }

  Future <List<DocumentSnapshot>> getCourseNames() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    print("test");
    final QuerySnapshot result =
    await db.collection('users').document(uid).collection("Grades").getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    //documents.forEach((data) => print(data.data));
    return documents;

  }

  Map<int, List<String>> getCourseByYear(List<DocumentSnapshot> documents){
    Map<int, List<String>> mapData = Map();

    for(int i =0; i<documents.length; i++) {
      int year = documents[i].data["year"];

      if (!mapData.containsKey(year)) {
        mapData[year] = <String>[];

      }

      mapData[year].add(documents[i].data["id"]);



    }
      print(mapData.length);


    return mapData;
  }


  List<int> getYears(List<DocumentSnapshot> documents) {

    List<int> years = <int>[];
    print(documents.length);
    for(int i =0; i<documents.length; i++){
      if(!years.contains(documents[i].data["year"]))
        years.add(documents[i].data["year"]);

    }

    return years;


  }

  void getData() async{
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    Map<String, dynamic> mapData;

    Future<QuerySnapshot> myListOfDocuments = db.collection("users").document(uid).collection("Grades").getDocuments();

    print("uis is $uid");
    await db.collection("users").document(uid).get().then((DocumentSnapshot data){
          mapData = data.data;
          print("data is $mapData");

    });

    String data = jsonEncode(mapData);
    print("got data from $data");
  }



}