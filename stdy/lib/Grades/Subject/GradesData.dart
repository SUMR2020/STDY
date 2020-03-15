import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/GoogleAPI/Firestore/GradesFirestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../Helper/Course.dart';
import '../Helper/AuditItem.dart';
import '../Helper/TaskItem.dart';
import '../Helper/GPATable.dart';
import '../../Schedule/Helper/Task.dart';
import 'package:validators/validators.dart';
class GradesData with ChangeNotifier{


  //Global variables-------------------------------------------------------------------------------------------------------------------------------------------
  GradesFirestore firestore;
  static List<Course> courses;
  static GPATable gpaTable;

  //Audit variables-------------------------------------------------------------------------------------------------------------------------------------------
  static  List<String> semesters = <String>["Fall", "Winter", "Summer"];

  static List<AuditItem> auditItems;

  static  double gpa;
  static double currGPA;

  //Course variables-------------------------------------------------------------------------------------------------------------------------------------------
  static String currCourseID;
  static List<TaskItem> taskItems;
  static List<Task> tasks;
  double grade;
  double weighted;
  String letterGrade;
  double totalWeights;

  //Task variables---------------------------------------------------------------------------------------------------------------------------------------------
  static String currTaskID;

  //Predictor variables----------------------------------------------------------------------------------------------------------------------------------------
  int predictCount;
  List<Course> currCoursePredict;
  String gpaNeededPredict;


  GradesData(){
    firestore = GradesFirestore();
    currCoursePredict = <Course>[];

  }

  //-------------------------------------------------------------------------------------------------------------------------------------------------------------
//Getters
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
  Task getTaskByID(String id){
    for(int i =0; i<courses.length;i++){
      if(tasks[i].id ==id){
        return tasks[i];
      }
    }
    return null;
  }

  Course getCourseByID(String id){
    for(int i =0; i<courses.length;i++){
      if(courses[i].id ==id){
        return courses[i];
      }
    }
    return null;
  }
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//Predictor Calculations
//-------------------------------------------------------------------------------------------------------------------------------------------------------------

  bool calculateGPAPredict(String goalGPA){

      double gpaNeed = double.parse(findNumberGPA(double.parse(goalGPA)));
      double gpa=0.0;

      for(int i =0; i<GradesData.courses.length; i++){
        if(!GradesData.courses[i].curr && !checkCurrCoursePredictExists(i)) {
          String grade = findNumberGPA(GradesData.courses[i].grade);
          //print(courseData[i].data["id"]);
          gpa+= double.parse(grade);
        }
      }

      for(int i =0; i<currCoursePredict.length; i++){
        String grade;
        if(currCoursePredict[i].gradeOption=="Letter"){
          grade = GPATable.grades.indexOf(currCoursePredict[i].inGrade).toString();
        }
        else if(currCoursePredict[i].gradeOption=="Percentage"){
          grade = findNumberGPA(double.parse(currCoursePredict[i].inGrade));
        }
        else{
          grade = findNumberGPA(currCoursePredict[i].weighted);
        }
        gpa+= double.parse(grade);

      }

      gpaNeededPredict = ( ( (gpaNeed*GradesData.courses.length)-gpa )/predictCount ).toString();
      return true;



  }

  void calculateCoursePredictCount(){
    predictCount = 0;
    for(int i =0; i<courses.length; i++) {

      if(courses[i].curr){
        predictCount+=1;
      }
    }
  }

  bool addCurrCoursePredict(int i){

    if(predictCount==1){
      return false;
    }
    currCoursePredict.add(courses[i]);
    predictCount-=1;
    return true;
  }

  void removeCurrCoursePredict(int i){

    currCoursePredict.removeWhere((c) => c.id == currCoursePredict[i].id);
    predictCount+=1;
  }

  bool checkCurrCoursePredictExists(int i){
    for(int k=0; k<currCoursePredict.length;k++){
      print(courses[i]);
      if(currCoursePredict[k].id==courses[i].id){
        return true;
      }
    }
    return false;
  }
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//REMOVERS
//-------------------------------------------------------------------------------------------------------------------------------------------------------------

  void removeTaskData(String id) async{
    print("id for removal is $id");
    await firestore.removeTask(id, currCourseID);
    await refreshCoursePage();
  }

  void removeCourseData(String id) async{

    await firestore.removeCourse(id);
    await refreshAuditPage();
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//ADDERS
//-------------------------------------------------------------------------------------------------------------------------------------------------------------

  void addPrevTaskFormData(String type, String name, double weight, int total, double grade, bool bonus) async{

    await firestore.addTaskData(name, currCourseID, 0, null, null, null, true, weight, grade, type, null, bonus, total, currCourseID);
    await refreshCoursePage();
  }

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

  refreshCoursePage() async{
    await fetchTaskObjects();
    await calculateGPA();
  }

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//FETCHERS
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<bool> fetchGradesData() async  {
      await fetchGPATable();
      await fetchCourseObjects();
      await fetchGPA();

    return true;

  }

  Future<bool> fetchTaskObjects() async{
    tasks = <Task>[];
    print("in fetch tasks");

    List<DocumentSnapshot> docs = await firestore.getTasksData(currCourseID);

    for (int i = 0; i < docs.length; i++) {

      Map<String, dynamic> data = docs[i].data;

      Task t = new Task.prev(data["type"],data["name"],"",data["id"],data["course"],data["onlyCourse"],data["bonus"], data["curr"], data["grade"],data["weight"],data["totalgrade"]);
      tasks.add(t);
    }

    generateTaskItems();

    return true;
  }

  Future<bool> fetchGPA() async{
    gpa = await firestore.getGPA(false);
    currGPA = await firestore.getGPA(true);

    return true;
  }

  Future<bool> fetchCourseObjects() async{
      courses = <Course>[];
      List<DocumentSnapshot> docs = await firestore.getCourseData();

      for (int i = 0; i < docs.length; i++) {
        Map<String, dynamic> data = docs[i].data;
        Course c = new Course(data["current"], data["grade"], data["code"], data["id"], data["semester"], data["year"],data["letter"],double.parse(data["totalweight"].toString()));
        courses.add(c);
      }
      generateAuditItems();

    return true;
  }

  Future<bool> fetchGPATable() async{
    Map<String, int> temp = await firestore.getGPATable();
    gpaTable = new GPATable(temp);
    return true;

  }


//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//PAGE UPDATERS
//-------------------------------------------------------------------------------------------------------------------------------------------------------------

  void generateTaskItems() {
    taskItems = <TaskItem>[];
    Map<String, List<Task>> mapTasks = getTasksByType();
    List<String> sortedKeys = mapTasks.keys.toList();

    sortedKeys.forEach((key) =>
        taskItems.add(
            TaskItem(
              headerValue: key.toString(),
              expandedValue: "This is a value thing",
              expandedText: mapTasks[key],
            )
        )
    );
  }

  Map<String, List<Task>> getTasksByType() {

    Map<String, List<Task>> mapData = Map();

    for (int i = 0; i < tasks.length; i++) {
      String type = tasks[i].type;
      if (!mapData.containsKey(type)) {
        mapData[type] = <Task>[];
      }
      mapData[type].add(tasks[i]);
    }

    return mapData;
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
      String sem = courses[i].sem + " " + courses[i].year.toString();

      if (!mapData.containsKey(sem)) {
        mapData[sem] = <Course>[];
      }

      mapData[sem].add(courses[i]);
    }
    return mapData;
  }




}
