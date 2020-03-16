class Course{
  bool curr;
  double grade;
  String id;
  String code;
  String sem;
  int year;
  String letterGrade;
  double weighted;
  String gradeOption;
  String inGrade;
  double totalWeight;

  Course(this.curr,this.grade, this.code, this.id, this.sem, this.year,this.letterGrade,this.totalWeight,this.weighted);

  @override
  String toString(){
    return "$curr,  $grade, $id, $sem, $year, $letterGrade";
  }
}