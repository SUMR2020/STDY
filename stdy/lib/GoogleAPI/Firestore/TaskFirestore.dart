import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/GoogleAPI/Firestore/MainFirestore.dart';
import 'package:study/Progress/Observer/ProgressPage.dart';


class TaskFireStore extends MainFirestore{

  TaskFireStore(): super();

  String getCourse (DocumentSnapshot a){
    return (a.data["id"].toString() +  a.data["semester"].toString() +  a.data["year"].toString());

  }

  Future<QuerySnapshot> getTasksForCourse(String course) async{
    QuerySnapshot q = await db
        .collection('users')
        .document(uid)
        .collection("Grades")
        .document(course)
        .collection("Tasks")
        .getDocuments();
    return q;
  }


  Future<DocumentReference> getTaskData(var task) async{
    DocumentReference q = await db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document(task.data["course"])
        .collection("Tasks")
        .document(task.data["id"]);
    return q;
  }

  Future<List> getDates(DocumentReference docRef) async{
    var doc = await docRef.get();
    var dates = doc.data["dates"];
    return dates;
  }

  Future<List> getDoneDates(DocumentReference docRef) async{
    var doc = await docRef.get();
    var dates = doc.data["done"];
    return dates;
  }

  void updateDates(DocumentReference docRef, List<DateTime> i){
    docRef.updateData({"dates": i});
  }

  void updateDaily(DocumentReference docRef) async{
    var  doc = await docRef.get();
    var daily = doc.data["daily"];
    docRef.updateData({"today": daily});
  }

  Future<bool> redistributeData(var task, String course) async {
    DocumentReference docRef = db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document(course)
        .collection("Tasks")
        .document(task.data["id"]);
    var before = await docRef.get();
    var days = before["dates"];
    docRef.updateData({"daily": (double.parse(task.data["toDo"]) / days.length).toStringAsFixed(2)});
  }

  Future<bool> updateProgressandDaily(
      String id, String course, String done) async {
    DocumentReference docRef = db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document(course)
        .collection("Tasks")
        .document(id);
    var before = await docRef.get();
    var goal = before["goal"];
    if (double.parse(done) >= double.parse(before["today"])) {
      print ("In if");
      docRef.updateData({"today": 0});
      var totalBefore = before["toDo"];
      double totalAfter = ((totalBefore) - double.parse(done));
      if (totalAfter < 0) totalAfter = 0;
      docRef.updateData({"toDo": totalAfter});
      var dates = before["dates"];
      List<DateTime> datesObjs = new List<DateTime>();
      for (Timestamp t in dates) {
        DateTime date = (t.toDate());
        datesObjs.add(DateTime(date.year, date.month, date.day));
      }
      DateTime today = DateTime.now();
      datesObjs.remove(DateTime(today.year, today.month, today.day));
      docRef.updateData({"dates": datesObjs});
    }
    else{
      print ("In else");
      var today = before["today"];
      today = (double.parse(today) - double.parse(done)).toStringAsFixed(2);
      docRef.updateData({"today": today});
      print ("after today");

    }
    print ("out");
    var progress = before["progress"];
    if (progress == null) progress = new List<String>();
    List<DateTime> doneDatesObjs = new List<DateTime>();
    var doneDays = before["done"];
    if (doneDays == null) doneDays = new List<String>();
    else {
      for (Timestamp t in doneDays) {
        DateTime date = (t.toDate());
        doneDatesObjs.add(DateTime(date.year, date.month, date.day));
      }
    }
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (doneDatesObjs.contains(today)){
      var last = progress.last;
      var add = double.parse(last) + double.parse(done);
      progress[progress.length-1] = add.toString();
    }
    else{
      if (goal == null) goal = new List<String>();
      goal.add(before["today"]);
      doneDatesObjs.add(today);
      progress.add(done);
    }
    docRef.updateData({"progress": progress});
    var totalBefore = before["toDo"];
    double totalAfter = ((totalBefore) - double.parse(done));
    if (totalAfter < 0) totalAfter = 0;
    docRef.updateData({"toDo": totalAfter});
    docRef.updateData({"goal": goal});
    // doneDatesObjs.add(DateTime(DateTime.now().year,DateTime.now().month, DateTime.now().day));
    docRef.updateData({"done": doneDatesObjs});
    var days = before["dates"];
    docRef.updateData({"daily": (totalAfter / days.length).toStringAsFixed(2)});
    return true;
  }

}
