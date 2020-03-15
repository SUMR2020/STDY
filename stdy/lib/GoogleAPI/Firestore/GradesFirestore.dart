import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/GoogleAPI/Firestore/MainFirestore.dart';

class GradesFirestore  extends MainFirestore{
  GradesFirestore(): super(){
    print("started grades");

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


//  GradeData() {
//    print("started grades");
//    if (letterGPA == null) {
//      getGPATable();
//    }
//    print(letterGPA);
//
//  }


  void updateGPA(double grade, double currGrade) async{
    await addingUid();
    print("$uid gpa has been updated to be $grade");
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
    if (grade.isNaN || grade==-1) {
      return "N/A";
    }
    String numberGPA = findNumberGPA(grade);

    return grades[int.parse(numberGPA)];
  }



  Future<Map<String, dynamic>> getCourse(String id) async {
    List<DocumentSnapshot> list = await getCourseData();
    for (int i = 0; i < list.length; i++) {
      if (list[i].documentID == id) {
        return list[i].data;
      }
    }
  }




void removeCourse(String id) async {
    await addingUid();
    print("uid for removing is $uid");
    /*
    List<DocumentSnapshot> tasks = await getTasks();
    for(int i =0; i<tasks.length; i++){
      remove_task(tasks[i].documentID, id);
    }*/

    db.collection("users")
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

  void addCourseData(String course, String semester,int year, bool curr, double grade,String letterGrade, String id) async {
    print ("ADD DATA");


    await db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document(id)
        .setData({
      "id": id,
      "year": year,
      "grade": grade,
      "semester": semester,
      "current": curr,
      "code": course,
      "letter": letterGrade
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

  Future <Map<String, int>> getGPATable() async {
    print("getting table");
    await addingUid();
    Map<String, int> gpaTable;

    await Firestore.instance.collection('gpa').document("Carleton").get().then((DocumentSnapshot ds) {
        gpaTable = Map<String, int>.from(ds.data);


    });
    print("assigned gpattable ${gpaTable.length}");
    return gpaTable;

  }


  Future<List<DocumentSnapshot>> getCourseData() async {

    final List<DocumentSnapshot> documents = await super.getCourseData();
    //documents.forEach((data) => print(data.data));
    currDocuments = documents;
    return documents;
  }

  Future<List<DocumentSnapshot>> getTasksData(String course) async {


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
    if (!exists) docRef.setData({"token": t, "gpa": -1, "currGpa": -1});
    else docRef.setData({"token": t}, merge: true);
  }
}