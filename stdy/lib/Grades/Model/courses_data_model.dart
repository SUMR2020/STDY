import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../grades_data.dart';

class CoursesDataModel {

  List<String> grades = [
    "F",
    "D-",
    "D",
    "D+",
    "C-",
    "C",
    "C+",
    "B-",
    "B",
    "B+",
    "A-",
    "A",
    "A+"
  ];

  List<DocumentSnapshot> currDocuments;
  String university = "Carleton";
  Map<String, dynamic> letterGPA;


  CoursesDataModel() {

  }
}