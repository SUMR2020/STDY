import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/Schedule/Helper/TaskList.dart';
import '../../GoogleAPI/Firestore/TaskFirestore.dart';
import '../Helper/Task.dart';
import '../Helper/TaskList.dart';

class TaskData{
  List<DocumentSnapshot> taskDocs;
  TaskList todayTasks = new TaskList();
  TaskList todayDoneTasks = new TaskList();
  TaskFireStore grades = new TaskFireStore();
  
  Future<DateTime> updateDay(DateTime d) async{
    DateTime now = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime check = new DateTime(d.year, d.month, d.day);
    if (check == now){
      return d;
    } else{
      var list = await grades.getCourseData();
      for (int i = 0; i < list.length; i++) {
        String course = grades.getCourse(list[i]);
        final QuerySnapshot courseTasks = await grades.getTasksForCourse(course);
        final List<DocumentSnapshot> documents = courseTasks.documents;
        for (var task in documents){
          DocumentReference docRef = await grades.getTaskData(task);
          var dates = await grades.getDates(docRef);
          List<DateTime> datesObjs = new List<DateTime>();
          for (Timestamp t in dates) {
            DateTime date = (t.toDate());
            if (!(date.isBefore(DateTime.now()))) datesObjs.add(DateTime(date.year, date.month, date.day));
          }
          grades.updateDates(docRef, datesObjs);
          grades.redistributeData(task, course);
          grades.updateDaily(docRef);
        }
      }
      return DateTime.now();
    }
  }

  Future<bool> getTasks() async {
    taskDocs = await grades.getTasks();
    for (DocumentSnapshot task in taskDocs) {
      var docRef = await grades.getTaskData(task);
      var dates = await  grades.getDates(docRef);
      List<DateTime> datesObjs = new List<DateTime>();
      for (Timestamp t in dates){
        DateTime date = (t.toDate());
        datesObjs.add(DateTime(date.year, date.month, date.day));
      }
      DateTime today = DateTime.now();
      if (datesObjs.contains(DateTime(today.year, today.month, today.day))) {
        Task t = new Task(task.data["type"], task.data["name"],task.data["today"], task.data["id"],task.data["course"],task.data["onlyCourse"]);
        todayTasks.add(t);
      }
    }
    return true;
  }

  Future<bool> getDoneTasks() async {
    taskDocs = await grades.getTasks();
    for (DocumentSnapshot task in taskDocs) {
      var docRef = await grades.getTaskData(task);
      var dates = await grades.getDoneDates(docRef);
      List<DateTime> datesObjs = new List<DateTime>();
      for (Timestamp t in dates) {
        DateTime date = (t.toDate());
        datesObjs.add(DateTime(date.year, date.month, date.day));
      }
      DateTime today = DateTime.now();
      if (datesObjs.contains(DateTime(today.year, today.month, today.day))) {
        Task t = new Task(
            task.data["type"], task.data["name"], task.data["today"].toString(),
            task.data["id"], task.data["course"], task.data["onlyCourse"]);
        todayDoneTasks.add(t);
      }
    }
    return true;
  }
}