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
  bool bonus;
  bool curr;
  bool forMarks;
  double grade;
  double weight;
  int totalGrade;
  DateTime due;
  int totalHours;




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

  Task.prev(String t, String n, String ti, String i, String c, String oc,bool b, bool cu, double g,double w,int tg, DateTime d, int th, bool fm){
    type = t;
    name = n;
    time = ti;
    id = i;
    course = c;
    onlyCourse = oc;
    bonus = b;
    curr = cu;
    grade = g;
    weight = w;
    totalGrade = tg;
    due = d;
    totalHours = th;
    forMarks = fm;

  }

  @override
  String toString(){
   return "$type, $name, $course, $bonus";
  }

  // checking if something is numeric
  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}