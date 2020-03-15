class Course{
  bool curr;
  double grade;
  String id;
  String code;
  String sem;
  int year;
  String letterGrade;
  double weighted;

  Course(this.curr,this.grade, this.code, this.id, this.sem, this.year,this.letterGrade);

  @override
  String toString(){
    return "$curr,  $grade, $id, $sem, $year, $letterGrade";
  }
}