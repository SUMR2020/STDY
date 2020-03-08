import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../grades/grades_data.dart';
import 'task.dart';
import 'calendar_api.dart';

class TaskManager{
  CalendarBuilder c = new CalendarBuilder();
  List<DocumentSnapshot> taskDocs;
  List<Task> todayTasks = new List<Task>();
  List<Task> todayDoneTasks = new List<Task>();
  GradeData grades = new GradeData();
  bool isSwitched = true;
  Map<DateTime, List> eventCal;
  calendar.CalendarApi events;
  EventList<Event> markedDateMap = new EventList<Event>();
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

  bool contains(Event i) {
    List events = markedDateMap.getEvents(i.date);
    for (Event e in events) {
      if (e == i) {
        return true;
      }
    }
    return false;
  }

  Future<bool> loadEvents() async {
    events = await c.gettingCalendar();
    eventCal = await c.getEventMap(events);
    var dates = eventCal.keys;
    var date;
    for (int i = 0; i < dates.length; i++) {
      date = dates.elementAt(i);
      for (var i = 0; i < eventCal[date].length; i++) {
        Event x = new Event(
          date: date,
          title: eventCal[date][i],
          icon: null,
        );
        if (!contains(x)) {
          markedDateMap.add(
              date,
              new Event(
                date: date,
                title: eventCal[date][i],
                icon: null,
              ));
        }
      }
    }
    return (true);
  }
}