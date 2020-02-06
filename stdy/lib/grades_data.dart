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


  void addData() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    bool exists=true;

    print("went into addData");

    await db.collection("users").document(uid).get().then((DocumentSnapshot data) {
      exists = data.exists;
      print("it exists db is $exists");

    });

    print("it exists is $exists");

    if(exists){
      await db.collection("users").document(uid).collection("Grades").document("ENGL1500").setData({"id": "COMP3004", "year": 2020, "grade": -1});

    }
    else{
      await db.collection("users").document(uid).setData({"gpa": -1});
      await db.collection("users").document(uid).collection("Grades").document("ENGL1500").setData({"id": "COMP3004","year": 2020, "grade": -1});

    }

    print("added data to $uid");

  }

  void getCourses() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    print("test");
    final QuerySnapshot result =
    await db.collection('users').document(uid).collection("Grades").getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data) => print(data.documentID));

  }


  void getData() async{
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    Map<String, dynamic> mapData;

    Future<QuerySnapshot> myListOfDocuments = db.collection("users").document(uid).collection("Grades").getDocuments();

    print("uis is $uid");
    await db.collection("users").document(uid).get().then((DocumentSnapshot data){
          print(data.exists);
          mapData = data.data;
          print("data is $mapData");

    });

    String data = jsonEncode(mapData);
    print("got data from $data");
  }



}