import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/GoogleAPI/Firestore/GradesFirestore.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/Schedule/Observer/CurrTaskFormPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../Helper/Course.dart';
import '../Helper/AuditItem.dart';
import '../Helper/GPATable.dart';


class GradesData with ChangeNotifier{

  GradesFirestore firestore;


  static  List<String> semesters = <String>["Fall", "Winter", "Summer"];
  static String _currCourseID;
  static List<Course> courses;
  static List<AuditItem> auditItems;
  static  double gpa;
  static double currGPA;
  static GPATable gpaTable;


  GradesData(){
    firestore = GradesFirestore();

  }



//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//REMOVERS
//-------------------------------------------------------------------------------------------------------------------------------------------------------------

void removeCourseData(String id) async{
    await firestore.removeCourse(id);
    await refreshAuditPage();
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//ADDERS
//-------------------------------------------------------------------------------------------------------------------------------------------------------------

  void addCourseFormData(String course, String semester,String strYear, bool curr, String strGrade) async{
    double grade = 0.0;
    int year =0;
    String letterGrade = 'CURR';

    if(curr) {
      var now = new DateTime.now();
      year = now.year;
      int month = now.month;

      if (month >= 1 && month < 5) semester = semesters[1];
      if (month >= 5 && month < 9) semester = semesters[2];
      if (month >= 9) semester = semesters[0];
      grade = -1;
    }
    else {
      year = int.parse(strYear);

      if (isNumeric((strGrade))) {
        grade = double.parse(strGrade);
        letterGrade = findLetterGPA(grade);

      }

      else {
        letterGrade = strGrade;
        grade = double.parse(convertLetterToDouble(letterGrade));

        //_addGrade =
      }
    }
    String id = (course + semester + year.toString()).replaceAll(' ', '');

    await firestore.addCourseData(course, semester, year, curr, grade,letterGrade, id);
    //Course c = new Course(curr, grade, course, id, semester, year,letterGrade);
    //courses.add(c);
    await refreshAuditPage();

  }

  //-------------------------------------------------------------------------------------------------------------------------------------------------------------
//UPDATERS
//-------------------------------------------------------------------------------------------------------------------------------------------------------------

  double calculateCurrGPA(bool curr) {
    double gpa = 0.0;
    int size = courses.length;

    for (int i = 0; i < courses.length; i++) {

      if (courses[i].curr) {

        if (curr && courses[i].weighted!=null) {
          gpa+= double.parse(findNumberGPA(courses[i].weighted));
        } else {
          size--;
        }
      }else {
        gpa+= double.parse(findNumberGPA(courses[i].grade));
      }

    }
    return gpa / size;
  }


  void calculateGPA() async{

    gpa = calculateCurrGPA(false);
    currGPA = calculateCurrGPA(true);
    await firestore.updateGPA(gpa, currGPA);

  }


//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//GRADE CONVERTERS
//-------------------------------------------------------------------------------------------------------------------------------------------------------------

  String convertLetterToDouble(String strVal) {

    if(GPATable.grades.contains(strVal)){
      String index = GPATable.grades.indexOf(strVal).toString().padLeft(2,'0');
      //gpaTable.table.forEach((k,v) => print('${k}: ${v}'));
      return gpaTable.table[index].toString();
    }
    return null;
  }

  String findNumberGPA(double grade) {

    List<String> letters = new List();

    gpaTable.table.forEach((k, v) => letters.add(k));
    letters.sort();

    String curr = letters[0];
    for (int i = 0; i < letters.length; i++) {
      String key = letters[i];

      if (gpaTable.table[key] > grade) {
        break;
      }
      curr = letters[i];
    }
    return curr;
  }

  String findLetterGPA(double grade) {
    if (grade.isNaN) {
      return "N/A";
    }
    String numberGPA = findNumberGPA(grade);

    return GPATable.grades[int.parse(numberGPA)];
  }

  String calculateSemGPA(String sem, int size) {
    double semGPA = 0.0;

    for (int i = 0; i < courses.length; i++) {

      String temp = courses[i].sem + " " + courses[i].year.toString();

      if (temp == sem) {
        if (courses[i].curr) {
          size--;
        } else {
          semGPA += double.parse(findNumberGPA(courses[i].grade));
        }
      }
    }
    semGPA = semGPA / size;

    if (semGPA.isNaN) {
      return "CURR";
    }

    return semGPA.toStringAsFixed(2);
  }

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//PAGE REFRESHERS
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
  refreshAuditPage() async{
    await fetchCourseObjects();
    await calculateGPA();
  }

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//FETCHERS
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<bool> fetchGradesData() async {
      await fetchGPATable();
      await fetchCourseObjects();
      await fetchGPA();


    return true;

  }

  Future<bool> fetchGPA() async{
    gpa = await firestore.getGPA(false);
    currGPA = await firestore.getGPA(true);
    print("old gpa is $gpa, current is $currGPA");

    return true;
  }



  Future<bool> fetchCourseObjects() async{
    print("in create");

      print("trying to add to null couruses");
      courses = <Course>[];
      List<DocumentSnapshot> docs = await firestore.getCourseData();

      for (int i = 0; i < docs.length; i++) {
        Map<String, dynamic> data = docs[i].data;
        Course c = new Course(data["current"], data["grade"], data["code"], data["id"], data["semester"], data["year"],data["letter"]);
        courses.add(c);
      }
      generateAuditItems();

    return true;
  }

  Future<bool> fetchGPATable() async{
    Map<String, int> temp = await firestore.getGPATable();
    print("got the temp data ${temp.length}");
    print("table is size opf ${temp.length}");

    gpaTable = new GPATable(temp);
    return true;

  }

  void generateAuditItems() {
    auditItems = <AuditItem>[];
    Map<String, List<Course>> mapCourses = getCoursesBySem();
    List<String> sortedKeys = mapCourses.keys.toList();

    sortedKeys.forEach((key) =>
        auditItems.add(
            AuditItem(
                headerValue: key.toString(),
                expandedText: mapCourses[key],
                semGPA: calculateSemGPA(key, mapCourses[key].length)
            )
        )
    );

  }

  Map<String, List<Course>> getCoursesBySem() {
    courses.sort((a, b) {
      int val = b.year - a.year;

      if (val == 0) {
        return a.sem.compareTo(b.sem);
      }
      return val;
    });


    Map<String, List<Course>> mapData = Map();

    for (int i = 0; i < courses.length; i++) {
      print(courses[i].toString());
      String sem = courses[i].sem + " " + courses[i].year.toString();

      if (!mapData.containsKey(sem)) {
        mapData[sem] = <Course>[];
      }

      mapData[sem].add(courses[i]);
    }
    print("returned map data");

    return mapData;
  }








}
