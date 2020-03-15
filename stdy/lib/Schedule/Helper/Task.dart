class Task {
  String type;
  String name;
  String time;
  String id;
  String course;
  String onlyCourse;
  bool bonus;
  bool curr;
  double grade;
  double weight;
  int totalGrade;

  Task(String t, String n, String ti, String i, String c, String oc) {
    type = t;
    name = n;
    time = ti;
    id = i;
    course = c;
    onlyCourse = oc;

  }

  Task.prev(String t, String n, String ti, String i, String c, String oc,bool b, bool cu, double g,double w,int tg){
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

  }

  @override
  String toString(){
   return "$type, $name, $course, $bonus";
  }
}