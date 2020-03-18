import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/Schedule/Helper/TaskList.dart';
import '../../GoogleAPI/Firestore/TaskFirestore.dart';
import '../Helper/Task.dart';
import '../Helper/TaskList.dart';
/*
TaskData
A class to obtain data from the database, and manipulate it to utilize it in ways
necessary.
    _taskDocs: all tasks
    todayTasks: tasks to be done today
    todayDoneTasks: tasks completed today
    taskManager: database persistence layer

Course
A helper class to document all of the courses that have been retrieved from the
database into aspects that are necessary to build the form (the course selection).
    _name: a private variable holding the course name
    _semester: a private variable holding the course semester
    _year: a private variable holding the course year

 */
// the helper Course class, defined and explained above
class Course{
  String _name;
  String _semester;
  int _year;
  Course (int y, String n, String s) {
    _name = n;
    _semester = s;
    _year = y;
  }
}

class TaskData {
  List<DocumentSnapshot> _taskDocs;
  TaskList todayTasks = new TaskList();
  TaskList todayDoneTasks = new TaskList();
  TaskFireStore taskManager = new TaskFireStore();
  List<Course> _courseObjs;


  Future<List<String>> getCourseNameList() async {
    List<String> _courseNames = List<String>();
    List<DocumentSnapshot> _courses = await taskManager.getCourseData();
    _courseObjs = List<Course>();
    for (var data in _courses) {
      if (data.data["current"] == true) {
        _courseObjs.add(new Course(
            data.data["year"], data.data["code"], data.data["semester"]));
      }
    }  _courseObjs.forEach((data) => _courseNames.add((data._name+" " + data._semester+ " " +(data._year.toString()))));
    return _courseNames;
  }

  Future<List<DocumentSnapshot>> getCourseData() async {
    return taskManager.getCourseData();
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
      String onlyC) async {
    taskManager.addTaskData(name, course, toDo, dates, dueDate, done, forMarks, null, null,
        type, daily, bonus, null, onlyC);
  }

  Future<DateTime> updateDay() async {
      print ("kil me");
      _taskDocs = await taskManager.getTasks();
      for (DocumentSnapshot task in _taskDocs) {
        print(task.data["name"]);
        var docRef = await taskManager.getTaskData(
            task.data["course"], task.data["id"]);
        var dates = await taskManager.allDates(docRef);
        if (dates == null) dates = new List<String>();
        List<DateTime> DoneDatesObjs = new List<DateTime>();
        for (Timestamp t in dates) {
          DateTime date = (t.toDate());
          DoneDatesObjs.add(DateTime(date.year, date.month, date.day));
        }
        DateTime today = DateTime.now();
        if (!DoneDatesObjs.contains(
            DateTime(today.year, today.month, today.day))) {
          DoneDatesObjs.add(today);
          var progress = await taskManager.getProgress(docRef);
          if (progress == null) progress = new List<String>();
          progress.add("0");
          var goal = await taskManager.getGoal(docRef);
          if (goal == null) goal = new List<String>();
          var data = await docRef.get();
          goal.add(data["today"]);
          docRef.updateData({"progress": progress});
          docRef.updateData({"goal": goal});
          docRef.updateData({"allday": DoneDatesObjs});
        }
        var currdates = await taskManager.getDates(docRef);
        List<DateTime> datesObjs = new List<DateTime>();
        for (Timestamp t in currdates) {
          DateTime date = (t.toDate());
          if (date.isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day-1)))
            datesObjs.add(DateTime(date.year, date.month, date.day));
        }
        docRef.updateData({"dates": datesObjs});
        var num = ((task.data["toDo"]) / datesObjs.length);
        docRef.updateData({
          "daily": (num.toStringAsFixed(2)).toString()
        });
       // taskManager.redistributeData(task, task.data["id"]);
      }

          // update dates, remove old

          // redistribute the data
  }

  Future<bool> getTasks() async {
    _taskDocs = await taskManager.getTasks();
    for (DocumentSnapshot task in _taskDocs) {
      print(task.toString());
      var docRef = await taskManager.getTaskData(task.data["course"], task.data["id"]);
      var dates = await taskManager.getDates(docRef);
      List<DateTime> datesObjs = new List<DateTime>();
      for (Timestamp t in dates) {
        DateTime date = (t.toDate());
        datesObjs.add(DateTime(date.year, date.month, date.day));
      }
      DateTime today = DateTime.now();
      if (datesObjs.contains(DateTime(today.year, today.month, today.day))) {
        Task t = new Task(
            task.data["type"],
            task.data["name"],
            task.data["today"],
            task.data["id"],
            task.data["course"],
            task.data["onlyCourse"]);
        todayTasks.add(t);
      }
    }
    return true;
  }

  Future<bool> getDoneTasks() async {
    _taskDocs = await taskManager.getTasks();
    for (DocumentSnapshot task in _taskDocs) {
      var docRef = await taskManager.getTaskData(task.data["course"], task.data["id"]);
      var dates = await taskManager.getDoneDates(docRef);
      List<DateTime> datesObjs = new List<DateTime>();
      for (Timestamp t in dates) {
        DateTime date = (t.toDate());
        datesObjs.add(DateTime(date.year, date.month, date.day));
      }
      DateTime today = DateTime.now();
      if (datesObjs.contains(DateTime(today.year, today.month, today.day))) {
        Task t = new Task(
            task.data["type"],
            task.data["name"],
            task.data["today"].toString(),
            task.data["id"],
            task.data["course"],
            task.data["onlyCourse"]);
        todayDoneTasks.add(t);
      }
    }
    return true;
  }

  bool printTasks(){
    while (todayTasks.moveNext()){
     print(todayTasks.current);
    }
  }

  Future<bool> updatingProgress(String id, String course, String done) async {
    var docRef = await taskManager.getTaskData(course, id);
    var goal = await taskManager.getGoal(docRef);
    bool complete = await taskManager.isDone(docRef, done);
    if (complete) {
      await taskManager.updateDoneToday(docRef);
      await taskManager.updateToDo(docRef, done);
      var dates = await taskManager.getDates(docRef);
      List<DateTime> datesObjs = new List<DateTime>();
      for (Timestamp t in dates) {
        DateTime date = (t.toDate());
        datesObjs.add(DateTime(date.year, date.month, date.day));
      }
      DateTime today = DateTime.now();
      datesObjs.remove(DateTime(today.year, today.month, today.day));
      taskManager.updateTask(course, id);
    }
    else {
      await taskManager.updateToday(docRef, done);
    }
    bool finish = await taskManager.updateProgressandDoneList(docRef, done);
    return finish;
  }
}
