import 'package:cloud_firestore/cloud_firestore.dart';
import '../../GoogleAPI/Firestore/TaskFirestore.dart';
import '../Helper/Task.dart';
import '../../GoogleAPI/Calendar/CalendarAPI.dart';

// class to manage tasks

class TaskManager{

  // getting
  List<DocumentSnapshot> taskDocs;
  List<Task> todayTasks = new List<Task>();
  List<Task> todayDoneTasks = new List<Task>();
  TaskFireStore grades = new TaskFireStore();

  Future<bool> getTasks() async {
    taskDocs = await grades.getTasks();
    for (DocumentSnapshot task in taskDocs) {
      var dates = (task.data['dates']);
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
      var dates = (task.data['done']);
      List<DateTime> datesObjs = new List<DateTime>();
      for (Timestamp t in dates){
        DateTime date = (t.toDate());
        datesObjs.add(DateTime(date.year, date.month, date.day));
      }
      DateTime today = DateTime.now();
      if (datesObjs.contains(DateTime(today.year, today.month, today.day))) {
        Task t = new Task(task.data["type"], task.data["name"],task.data["today"].toString(), task.data["id"],task.data["course"], task.data["onlyCourse"]);
        todayDoneTasks.add(t);
      }
    }
    print (todayDoneTasks);
    return true;
  }
}