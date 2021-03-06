import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class MainFirestore {
  // receiving the authorization and database instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final db = Firestore.instance;
  FirebaseUser user;
  var uid;

  // setting the uid, this is async, so there must be a function for it
  addingUid() async {
    FirebaseUser user = await _auth.currentUser();
    uid = user.uid;
  }

  MainFirestore(){
    addingUid();
  }


  Future<List<DocumentSnapshot>> getCourseData() async {
    await addingUid();
    final QuerySnapshot result = await db
        .collection('users')
        .document(uid)
        .collection("Grades")
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    //documents.forEach((data) => print(data.data));
    return documents;
  }
  void addTaskData(
      String name,
      String course,
      int toDo,
      List<DateTime> dates,
      DateTime dueDate,
      List<int> done,
      bool forMarks,
      double weight,
      double grade,
      String type,
      String daily,
      bool bonus,
      int total,
      String onlyC,
      bool curr) async {
    await addingUid();
    String id = (new DateTime.now().millisecondsSinceEpoch).toString();
    course = course.replaceAll(" ", "");
    await db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document((course))
        .collection("Tasks")
        .document(id)
        .setData({
      "id": id,
      "name": name,
      "course": course,
      "toDo": toDo,
      "dates": dates,
      "due": dueDate,
      "progress": done,
      "goal": new List<int>(),
      "forMarks": forMarks,
      "weight": weight,
      "grade": grade,
      "type": type,
      "daily": daily,
      "curr": curr,
      "bonus": bonus,
      "totalgrade": total,
      "today": daily,
      "done" : new List<DateTime>(),
      "onlyCourse" : onlyC,
      "allday":  new List<DateTime>(),
    });

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

  Future<List<DocumentSnapshot>> getTasks() async {
    await addingUid();
    List<DocumentSnapshot> allTasks = new List<DocumentSnapshot>();
    List<DocumentSnapshot> courses = await getCourseData();
    for (DocumentSnapshot course in courses) {
      String name = course.data["id"].toString();
      final QuerySnapshot courseTasks = await db
          .collection('users')
          .document(uid)
          .collection("Grades")
          .document(name)
          .collection("Tasks")
          .getDocuments();
      final List<DocumentSnapshot> documents = courseTasks.documents;
      documents.forEach((data) => allTasks.add(data));
    }
    print ("taskdata");
    print(allTasks.toString());
    return allTasks;
  }

  updateTask(String i, String c);
  getTaskData(String i, String x);

}