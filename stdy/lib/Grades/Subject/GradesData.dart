import 'package:study/Grades/Helper/Course.dart';
import 'package:study/Schedule/Helper/Task.dart';

class GradesData {

  static List<Course> courses;
  static List<Task> tasks;
  static List<String> grades = ["F", "D-", "D", "D+", "C-", "C", "C+", "B-", "B", "B+", "A-", "A", "A+"];
  
  static Future<String> convertLetterToDouble(String strVal) async {
    await addingUid();
    if (letterGPA == null) {
      await getGPATable();
    }
    if(grades.contains(strVal)){
      String index = grades.indexOf(strVal).toString().padLeft(2,'0');
      letterGPA.forEach((k,v) => print('${k}: ${v}'));
      return letterGPA[index].toString();

    }
    return null;
  }





}