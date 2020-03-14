/*
Task
A helper class to store task data.
  task: task type
  name: task name
  time: amount of time/pages
  id: task id
  course: task course (string with sem year and name)
  onlyCourse: course name
 */
class Task {
  String type;
  String name;
  String time;
  String id;
  String course;
  String onlyCourse;

  // empty task object ctor
  Task.Empty();
  Task(String t, String n, String ti, String i, String c, String oc) {
    type = t;
    name = n;
    time = ti;
    id = i;
    course = c;
    onlyCourse = oc;
  }

  // checking if something is numeric
  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}