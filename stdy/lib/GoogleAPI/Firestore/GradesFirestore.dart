import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/GoogleAPI/Firestore/MainFirestore.dart';

class GradesFirestore  extends MainFirestore{

  GradesFirestore(): super(){
    print("started grades");

}

  void updateGPA(double grade, double currGrade) async{
    await addingUid();

    await db.collection("users").document(uid).setData({"gpa": grade, "currGpa": currGrade}, merge: true);
  }

void removeCourse(String id) async {
    await addingUid();
    List<DocumentSnapshot> tasks = await getTasks();
    for(int i =0; i<tasks.length; i++){
      await updateTask(tasks[i].documentID, id);
    }
    db.collection("users")
        .document(uid)
        .collection("Grades")
        .document(id)
        .delete();

    print("removed $id");
  }

  void updateTask(String id, String course) async {
    await addingUid();
    //print("removing task $id for course$course");
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
      "letter": letterGrade,
      "totalweight": 0,
    });

    print("added data to $uid");
  }

  Future <Map<String, int>> getGPATable() async {

    await addingUid();
    Map<String, int> gpaTable;

    await Firestore.instance.collection('gpa').document("Carleton").get().then((DocumentSnapshot ds) {
        gpaTable = Map<String, int>.from(ds.data);
    });

    return gpaTable;

  }

  Future<List<DocumentSnapshot>> getTaskData(String course, String x) async {
    await addingUid();
    final QuerySnapshot result = await db
        .collection('users')
        .document(uid)
        .collection("Grades")
        .document(course)
        .collection("Tasks")
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    return documents;
  }

  Future<double>  getGPA(bool curr) async {
    double val;
    await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .then((DocumentSnapshot ds) {
      if (curr) {
        val = double.parse(ds.data["currGpa"].toString());
      }
      else {
        print(ds.data["gpa"]);
        val = double.parse(ds.data["gpa"].toString());
      }

      // use ds as a snapshot
    });
  }

  void setCourseGrade(String course, double grade, double weighted, double totalWeight) async{
    course = course.replaceAll(" ", "");

    await db.collection("users").document(uid).collection("Grades").document((course)).updateData(
        {"grade": grade,"weighted": weighted, "totalWeight": totalWeight});
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