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

  void remove_data(String id) async{
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    db.collection("users").document(uid).collection("Grades").document(id).delete();
    print("removed $id");

  }

  void addData(List<String> data) async {

    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    bool exists=true;
    String course = data[0];
    String semester = data[1];
    int year = int.parse(data[2]);



    await db.collection("users").document(uid).get().then((DocumentSnapshot data) {
      exists = data.exists;

    });

    if(!exists) {
      await db.collection("users").document(uid).setData({"gpa": -1});
    }
      await db.collection("users").document(uid).collection("Grades").document(data.join().replaceAll(' ','')).setData(
          {"id": course,"year": year, "grade": -1,"semester": semester}
          );

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

  Map<String, List<String>> getCourseByYear(List<DocumentSnapshot> documents){
    Map<String, List<String>> mapData = Map();

    for(int i =0; i<documents.length; i++) {
      String sem =  documents[i].data["semester"]+" "+documents[i].data["year"].toString();

      if (!mapData.containsKey(sem)) {
        mapData[sem] = <String>[];

      }

      mapData[sem].add(documents[i].data["id"]);

    }


    return mapData;
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