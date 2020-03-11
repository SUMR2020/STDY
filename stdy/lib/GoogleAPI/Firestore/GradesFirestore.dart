import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/GoogleAPI/Firestore/MainFirestore.dart';

class GradesFirestore  extends MainFirestore{
  GradesFirestore(): super(){
    print("started grades");
    if (letterGPA == null) {
      getGPATable();
    }
    print(letterGPA);
  }

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
  Future<String> convertLetterToDouble(String strVal) async {
    if (letterGPA == null) {
      await getGPATable();
    }
    if(grades.contains(strVal)){
      String index = grades.indexOf(strVal).toString().padLeft(2,'0');
      letterGPA.forEach((k,v) => print('${k}: ${v}'));
      return letterGPA[index].toString();

    }
    return null;
  }

//  GradeData() {
//    print("started grades");
//    if (letterGPA == null) {
//      getGPATable();
//    }
//    print(letterGPA);
//
//  }

  double calculateCurrGPA(bool curr, List<DocumentSnapshot> GradesFirestore) {
    double gpa = 0.0;
    int size = GradesFirestore.length;

    for (int i = 0; i < GradesFirestore.length; i++) {
      Map<String, dynamic> doc = GradesFirestore[i].data;
      double temp;

      if (doc["taken"] == "CURR") {

        if (curr && doc.containsKey("weighted")) {
          gpa+= double.parse(findNumberGPA(doc["weighted"]));
        } else {
          size--;
        }
      }else {
        gpa+= double.parse(findNumberGPA(doc["grade"]));
      }

    }
    return gpa / size;
  }


  void calculateGPA(List<DocumentSnapshot> GradesFirestore) async{
    if(GradesFirestore==null){
      GradesFirestore = await getCourseData();
    }
    double grade = calculateCurrGPA(false, GradesFirestore);
    double currGrade = calculateCurrGPA(true, GradesFirestore);
    await db.collection("users").document(uid).setData({"gpa": grade, "currGpa": currGrade}, merge: true);
  }

  Future<double>  getGPA(bool curr) async{
    double val;
    await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .then((DocumentSnapshot ds) {
      if(curr) {
        val= double.parse(ds.data["currGpa"].toString());
      }
      else{
        print (ds.data["gpa"]);
        val= double.parse(ds.data["gpa"].toString());
      }

      // use ds as a snapshot
    });

    print("returned $val");

    return val;
  }

  String findNumberGPA(double grade) {
    //List<String> letters = letterGPA.keys.toList()..sort();
    List<String> letters = new List();
    letterGPA.forEach((k, v) => letters.add(k));
    letters.sort();

    String curr = letters[0];
    for (int i = 0; i < letters.length; i++) {
      String key = letters[i];

      if (letterGPA[key] > grade) {
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

    return grades[int.parse(numberGPA)];
  }

  String getCourseGrade(String course) {
    for (int i = 0; i < currDocuments.length; i++) {
      if (currDocuments[i].documentID == course) {
        if (currDocuments[i].data["taken"] == "CURR") {
          if (currDocuments[i].data.containsKey("weighted")) {
            double grade = currDocuments[i].data["weighted"];
            String numberGPA = findNumberGPA(grade);
            return "CURR (${grades[int.parse(numberGPA)]})";
          } else {
            return "CURR";
          }
        } else {
          double grade = currDocuments[i].data["grade"];
          String numberGPA = findNumberGPA(grade);
          return grades[int.parse(numberGPA)];
        }
      }
    }
    return "N/A";
  }

  Future<Map<String, dynamic>> getCourse(String id) async {
    List<DocumentSnapshot> list = await getCourseData();
    for (int i = 0; i < list.length; i++) {
      if (list[i].documentID == id) {
        return list[i].data;
      }
    }
  }


  String calculateSemGPA(String sem, int size) {
    double gpa = 0.0;

    List<String> letters = new List();

    //print("calcsemGPA got data from $letterGPA");
    letterGPA.forEach((k, v) => letters.add(k));
    letters.sort();
    //print("letters are $letters");

    for (int i = 0; i < currDocuments.length; i++) {
      String temp = currDocuments[i].data["semester"] +
          " " +
          currDocuments[i].data["year"].toString();

      if (temp == sem) {
        if (currDocuments[i].data["taken"] == "CURR") {
          size--;
        } else {
          gpa += double.parse(findNumberGPA(currDocuments[i].data["grade"]));
        }
      }
    }
    gpa = gpa / size;

    if (gpa.isNaN) {
      return "CURR";
    }

    return gpa.toStringAsFixed(2);
  }

void remove_course(String id) async {
    List<DocumentSnapshot> tasks = await getTasks();
    for(int i =0; i<tasks.length; i++){
      remove_task(tasks[i].documentID, id);
    }

    db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document(id)
        .delete();
    print("removed $id");
  }

  void remove_task(String id, String course) async {
    print("removing task $id for course$course");
    db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document(course)
        .collection("Tasks")
        .document(id)
        .delete();
    print("removed $id");
  }

  void addData(List<String> data) async {
    print ("ADD DATA");
    print (uid);
    if (data == null) {
      return;
    }
    bool exists = true;
    String course = data[0];
    String semester = data[1];
    int year = int.parse(data[2]);
    String currCourse;

    double grade = 0.0;
    if (data[3] == "CURR") {
      currCourse = "CURR";
    } else {
      grade = double.parse(data[3]);
      currCourse = "PAST";
    }

    String id = (data[0] + data[1] + data[2]).replaceAll(' ', '');

    await db
        .collection("users")
        .document(uid)
        .get()
        .then((DocumentSnapshot data) {
      exists = data.exists;
    });

    if (!exists) {
      print("does not exist");
      await db.collection("users").document(uid).setData({"gpa": -1, "currGpa": -1});
    }
    await db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document(id)
        .setData({
      "id": course,
      "year": year,
      "grade": grade,
      "semester": semester,
      "taken": currCourse
    });

    print("added data to $uid");
  }

  void addTaskGrade(String name, String course, List<String> gradeInput) async {
    print("adding $name to $course");

    double weight = double.parse(gradeInput[0]);
    double total = double.parse(gradeInput[1]);
    double grade = double.parse(gradeInput[2]);

    course = course.replaceAll(" ", "");
    await db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document((course))
        .collection("Tasks")
        .document(name)
        .updateData({"weight": weight, "totalgrade": total, "grade": grade});

    print("added data to $uid");
  }


  void addPastTaskData(String course, List<String> data) async {
    String type = data[0];
    String name = data[1];
    double weight = double.parse(data[2]);
    double total = double.parse(data[3]);
    double grade = double.parse(data[4]);
    bool bonus = false;
    print("bonus is ${data[5]}");
    if(data[5]=='true'){
      bonus = true;
    }
    String id = (new DateTime.now().millisecondsSinceEpoch).toString();



    await db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document((course))
        .collection("Tasks")
        .document(name)
        .setData({
      "curr": false,
      "name": name,
      "course": course,
      "weight": weight,
      "grade": grade,
      "type": type,
      "total": total
    });
  }

//Future <Map<String, int>>
  void getGPATable() async {
    final QuerySnapshot result = await db.collection('gpa').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    for (int i = 0; i < documents.length; i++) {
      if (documents[i].documentID == university) {

        letterGPA = documents[i].data;
      }
    }

    print("test got letter gpa");
  }


  Future<List<DocumentSnapshot>> getCourseData() async {
    if (letterGPA == null) {
      getGPATable();
    }
    final List<DocumentSnapshot> documents = await super.getCourseData();
    //documents.forEach((data) => print(data.data));
    currDocuments = documents;
    return documents;
  }

  Future<List<DocumentSnapshot>> getTasksData(String course) async {
    if (letterGPA == null) {
      //print("letter is null");
      getGPATable();
    } else {
      //print("letter isnt");
    }


    final QuerySnapshot result = await db
        .collection('users')
        .document(uid)
        .collection("Grades")
        .document(course)
        .collection("Tasks")
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    //documents.forEach((data) => print(data.data));
    currDocuments = documents;

    return documents;
  }

  void setCourseGrade(String course, double grade, double weighted, double totalWeight) async{
    course = course.replaceAll(" ", "");

    await db.collection("users").document(uid).collection("Grades").document((course)).updateData(
        {"grade": grade,"weighted": weighted, "totalWeight": totalWeight});
  }

  Map<String, List<Map<String, dynamic>>> getTasksByType(
      List<DocumentSnapshot> documents) {


    Map<String, List<Map<String, dynamic>>> mapData = Map();

    for (int i = 0; i < documents.length; i++) {
      String type = documents[i].data["type"];
      if (!mapData.containsKey(type)) {
        mapData[type] = <Map<String, dynamic>>[];
      }
      mapData[type].add(documents[i].data);
    }

    return mapData;
  }

  Map<String, List<Map<String, dynamic>>> getCourseNameSem(
      List<DocumentSnapshot> documents) {
    documents.sort((a, b) {
      String aSem = a.data["semester"];
      String bSem = b.data["semester"];
      var aYear = a.data["year"];
      var bYear = b.data["year"];
      int val = bYear - aYear;
      ;

      if (val == 0) {
        return aSem.compareTo(bSem);
      }
      return val;
    });

    Map<String, List<Map<String, dynamic>>> mapData = Map();

    for (int i = 0; i < documents.length; i++) {
      String sem = documents[i].data["semester"] +
          " " +
          documents[i].data["year"].toString();

      if (!mapData.containsKey(sem)) {
        mapData[sem] = <Map<String, dynamic>>[];
      }

      mapData[sem].add(documents[i].data);
    }
    print("returned map data");

    return mapData;
  }

  void addingTokenData(String t) async{
    DocumentReference docRef = db.collection("users").document(uid);
    bool exists = false;
    await db
        .collection("users")
        .document(uid)
        .get()
        .then((DocumentSnapshot data) {
      exists = data.exists;
    });
    print ("POOP");
    if (!exists) docRef.setData({"token": t, "gpa": -1, "currGpa": -1});
    else docRef.setData({"token": t}, merge: true);
  }
}