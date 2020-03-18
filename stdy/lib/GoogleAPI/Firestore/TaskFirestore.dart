import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/GoogleAPI/Firestore/MainFirestore.dart';

/*
TaskFirestore
A DAO class that accesses the database in order to preform low level data
access and data addition methods.
*/

class TaskFireStore extends MainFirestore{

  TaskFireStore(): super();

  String getCourse (DocumentSnapshot a){
    return (a.data["id"].toString() +  a.data["semester"].toString() +  a.data["year"].toString());

  }

  Future<QuerySnapshot> getTasksForCourse(String course) async{
    await addingUid();
    QuerySnapshot q = await db
        .collection('users')
        .document(uid)
        .collection("Grades")
        .document(course)
        .collection("Tasks")
        .getDocuments();
    return q;
  }


  Future<DocumentReference> getTaskData(String c, String i) async{
    await addingUid();
    DocumentReference q = await db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document(c)
        .collection("Tasks")
        .document(i);
    return q;
  }

  Future<List> getDates(DocumentReference docRef) async{
    await addingUid();
    var doc = await docRef.get();
    var dates = doc.data["dates"];
    return dates;
  }

  Future<List> getDoneDates(DocumentReference docRef) async{
    await addingUid();
    var doc = await docRef.get();
    var dates = doc.data["done"];
    return dates;
  }

  Future<List> allDates(DocumentReference docRef) async{
    await addingUid();
    var doc = await docRef.get();
    var dates = doc.data["allday"];
    return dates;
  }

  void updateTask(String i, String c) async{
    await addingUid();
    DocumentReference q = await db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document(c)
        .collection("Tasks")
        .document(i);
    q.updateData({"dates": i});
  }

  void updateDaily(DocumentReference docRef) async{
    var  doc = await docRef.get();
    var daily = doc.data["daily"];
    docRef.updateData({"today": daily});
  }

  Future<bool> redistributeData(var task, String course) async {
    await addingUid();
    DocumentReference docRef = db
        .collection("users")
        .document(uid)
        .collection("Grades")
        .document(course)
        .collection("Tasks")
        .document(task.data["id"]);
    var before = await docRef.get();
    var days = before["dates"];
    docRef.updateData({
      "daily": (double.parse(task.data["toDo"]) / days.length).toStringAsFixed(
          2)
    });
  }
    Future<List> getGoal(DocumentReference d) async{
      var data = await d.get();
      var goal = data["goal"];
      return (goal);
    }

  Future<List> getProgress(DocumentReference d) async{
    var data = await d.get();
    var goal = data["progress"];
    return (goal);
  }


  Future<bool> isDone (DocumentReference d, String done) async {
     var data = await d.get();
     if (double.parse(done) >= double.parse(data["today"])) {
       return true;
     }
     return false;
   }

   void updateToDo(DocumentReference docRef, String done) async{
     var before = await docRef.get();
     var totalBefore = before["toDo"];
     double totalAfter = ((totalBefore) - double.parse(done));
     if (totalAfter < 0) totalAfter = 0;
     docRef.updateData({"toDo": totalAfter});
   }

   void updateDoneToday(DocumentReference docRef) async {
     docRef.updateData({"today": 0});
   }

   void updateToday(DocumentReference docRef, String done) async{
    var before = await docRef.get();
    var today = before["today"];
     today = (double.parse(today) - double.parse(done)).toStringAsFixed(2);
     docRef.updateData({"today": today});
   }


  Future<bool> updateProgressandDoneList(DocumentReference docRef, String done) async {
    var before = await docRef.get();
    var goal = before["goal"];
    var progress = before["progress"];
    if (progress == null) progress = new List<String>();
    List<DateTime> doneDatesObjs = new List<DateTime>();
    var doneDays = before["allday"];
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
