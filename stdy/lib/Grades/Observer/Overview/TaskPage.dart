
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../UpdateApp/Subject/SettingsData.dart';
import 'package:intl/intl.dart';
import '../../Subject/GradesData.dart';

class TaskPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return TaskState();
  }
}

class TaskState extends State<TaskPage> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  bool bonus;
  bool curr;
  bool completeTask;
  String name;
  String grade;
  String weight;
  String totalGrade;
  GradesData gradesData;

  TaskState(){
    gradesData = new GradesData();
    print("is is ${GradesData.currTaskID}");

    name = gradesData.getTaskByID(GradesData.currTaskID).name;
    curr = gradesData.getTaskByID(GradesData.currTaskID).curr;
    grade = gradesData.getTaskByID(GradesData.currTaskID).grade.toString();
    weight = gradesData.getTaskByID(GradesData.currTaskID).weight.toString();
    totalGrade = gradesData.getTaskByID(GradesData.currTaskID).totalGrade.toString();
    bonus = gradesData.getTaskByID(GradesData.currTaskID).bonus;

    if(curr) {
      completeTask = false;
    }
    else{
      completeTask = true;
    }


  }

  String _validateName(String value) {
    if (value.isEmpty && completeTask) return 'Please enter a valid name.';
    return null;
  }
  String _validateGrade(String value) {
    if (value.isEmpty && completeTask) return 'Please enter a valid grade.';
    return null;
  }
  String _validateTotal(String value) {
    if (value.isEmpty && completeTask) return 'Please enter a valid total mark.';
    return null;
  }
  String _validateWeight(String value) {
    print("in validate weight and it is ${value.isEmpty} and $completeTask");

    if (value.isEmpty && completeTask) {
      print("returning invalid");
      return 'Please enter a valid task weight.';
    }
    double val = double.parse(value);
    if(val+gradesData.getCourseByID(GradesData.currCourseID).totalWeight>100 && !bonus && completeTask)
      return 'Total course weight exceeds 100. Enter weight less than ${100-gradesData.getCourseByID(GradesData.currCourseID).totalWeight}\n or select bonus';
    return null;
  }

  String formatTimestamp(int timestamp) {
    var format = new DateFormat('d MMM, hh:mm a');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return format.format(date);
  }

  List<Widget> taskInfo(BuildContext context){
    double percent;

    if(gradesData.getTaskByID(GradesData.currTaskID).grade!=null){

      percent = double.parse(grade) / int.parse(totalGrade);
      double gradeWeighted =  percent* double.parse(weight);
      gradeWeighted = double.parse(gradeWeighted.toStringAsFixed(1));
      percent = double.parse((percent*100).toStringAsFixed(1));

    }

    List<Widget> tasks = <Widget>[
      buildTaskInfo(),

      Column(
        children: curr?buildCurrInput():buildCompletedInput(false),
      ),

      SizedBox(
        width: double.infinity,
        child:  RaisedButton(

          child: Text('Save Changes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0 + fontScale,
              )
          ),
          onPressed: (){
            saveChanges();
          },
        ),
      )
    ];

    return tasks;
  }
  Widget buildBonus(){
    return CheckboxListTile(
      title: Text("Bonus task",
        style: TextStyle(
          fontSize: 16.0 + fontScale,
        ),),
      value: bonus,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (bool value) {
        setState(() {
          bonus = value;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
  List<Widget> buildCurrInput(){
    return [
      new TextFormField(
          style: TextStyle(
            fontSize: 16.0 + fontScale,
          ),
          decoration: new InputDecoration(
            labelText: "Task name",
          ),
          initialValue: gradesData.getTaskByID(GradesData.currTaskID).name,
          validator: this._validateName,
          onSaved: (String value) {
            name = value;
          }),
      gradesData.getTaskByID(GradesData.currTaskID).forMarks?buildBonus():Container(),
      gradesData.getTaskByID(GradesData.currTaskID).forMarks?
      new CheckboxListTile(
        title: Text("Complete task?",
          style: TextStyle(
            fontSize: 16.0 + fontScale,
          ),),
        value: completeTask,
        activeColor: Theme.of(context).primaryColor,
        onChanged: (bool value) {
          setState(() {
            completeTask = value;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      ):Container(),
    new Visibility(
      visible: completeTask,
      child: Column(
        children: buildCompletedInput(true),
        )
      )
    ];
  }

  List<Widget> buildCompletedInput(bool comp){
    return [
      comp?Container():new TextFormField(
        style: TextStyle(
          fontSize: 16.0 + fontScale,
        ),
        decoration: new InputDecoration(
          labelText: "Task name",
        ),
        initialValue: gradesData.getTaskByID(GradesData.currTaskID).name,
        validator: this._validateName,
        onSaved: (String value) {
          name = value;
        }),
      new TextFormField(//remove decimal if its 0.
          style: TextStyle(
            fontSize: 16.0 + fontScale,
          ),
          decoration: new InputDecoration(
            labelText: "Task grade",
          ),
          keyboardType: TextInputType.number,
          initialValue: comp?null:grade.toString(),
          validator: this._validateGrade,
          onSaved: (String value) {
            grade = value;
          }),
      new TextFormField(
          style: TextStyle(
            fontSize: 16.0 + fontScale,
          ),
          decoration: new InputDecoration(
            labelText: "Task total marks",
          ),
          keyboardType: TextInputType.number,
          initialValue: comp?null:totalGrade.toString(),
          validator: this._validateTotal,
          onSaved: (String value) {
            totalGrade = value;
          }),
      new TextFormField(
          style: TextStyle(
            fontSize: 16.0 + fontScale,
          ),
          decoration: new InputDecoration(
            labelText: "Task weight",
          ),
          keyboardType: TextInputType.number,
          initialValue: comp?null:weight.toString(),
          validator: this._validateWeight,
          onSaved: (String value) {
            weight = value;
          }),
      comp?Container():buildBonus(),
    ];
  }

  void saveChanges() async{
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      double g;
      int t;
      double w;

      if(curr){
        if(completeTask){
          curr = false;
          g = double.parse(grade);
          t = int.parse(totalGrade);
          w = double.parse(weight);
        }
      }
     else {
        g = double.parse(grade);
        t = int.parse(totalGrade);
        w = double.parse(weight);
      }

      await gradesData.updateTaskData(
          name,
          w,
          g,
          t,
          bonus,
          curr);
      setState(() {});
    }
    if(curr && completeTask){
      (context as Element).reassemble();
    }

  }

  bool checkFormFilled(){
    if(curr && completeTask){
      return true;
    }
    _formKey.currentState.save();

    if(name != gradesData.getTaskByID(GradesData.currTaskID).name ||
        curr != gradesData.getTaskByID(GradesData.currTaskID).curr ||
        grade != gradesData.getTaskByID(GradesData.currTaskID).grade.toString() ||
        weight != gradesData.getTaskByID(GradesData.currTaskID).weight.toString() ||
        totalGrade != gradesData.getTaskByID(GradesData.currTaskID).totalGrade.toString() ||
        bonus != gradesData.getTaskByID(GradesData.currTaskID).bonus){
      return true;
    }
    return false;
  }

  Future<bool> _onWillPop() async {
    if(checkFormFilled()) {
      return (await showDialog(
        context: context,
        builder: (context) =>
        new AlertDialog(
          title: new Text('Quit'),
          content: new Text('Do you want to discard unsaved changes?'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: new Text('No'),
            ),
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: new Text('Yes'),
            ),
          ],
        ),
      )) ?? false;
    }
    return true;
  }

  Widget buildTaskInfo(){

    double hei = 180;

    return Padding(
        padding: EdgeInsets.all(10.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.1,
          height: hei ,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("${gradesData.getTaskByID(GradesData.currTaskID).type.toUpperCase()}: ${gradesData.getTaskByID(GradesData.currTaskID).name}",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),),
                ),
                currTaskColumn(),

              ],
            ),
          ),
        )
    );
  }

  Widget currTaskColumn(){
    if(gradesData.getTaskByID(GradesData.currTaskID).curr){
      print("its current with ${gradesData.getTaskByID(GradesData.currTaskID).time}");
      return Column(
        children: <Widget>[
          statsRow("Due", DateFormat('yMMMEd').format(gradesData.getTaskByID(GradesData.currTaskID).due)),
          statsRow("Total hours", gradesData.getTaskByID(GradesData.currTaskID).totalHours.toString()),
        ],
      );
    }
    else{
      String earned='N/A';
      String weighted='N/A';
      double percent;

      if(gradesData.getTaskByID(GradesData.currTaskID).grade!=null){

        percent = double.parse(grade) / int.parse(totalGrade);
        double gradeWeighted =  percent* double.parse(weight);
        gradeWeighted = double.parse(gradeWeighted.toStringAsFixed(1));
        percent = double.parse((percent*100).toStringAsFixed(1));

        earned = "$grade/$totalGrade";
        weighted = "$gradeWeighted/$weight";

      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          statsColumn("Weighted Grade", weighted),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("$percent%",
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),),
          ),
          statsColumn("Actual Grade", gradesData.getCourseByID(GradesData.currCourseID).grade!=-1.0? earned:"N/A"),
        ],
      );
    }

  }

  Widget statsRow(String title, String text){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("$title: $text ",
            style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(gradesData.getTaskByID(GradesData.currTaskID).time,
            style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),),
        ),
      ],
    );
  }

  Widget statsColumn(String title, String text){

    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text(title,
              style: TextStyle(
                fontSize: 16.0+fontScale,
                color: Colors.white,
              ),),
            Text(text!='null'&& text!='NaN'? "$text%":"N/A",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),),
          ],
        )
    );
  }



  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _onWillPop,
          child:  Scaffold(
        appBar: new AppBar(
            iconTheme: IconThemeData(
              color: Theme.of(context).primaryColor, //change your color here
            ),
            centerTitle: true,
            backgroundColor: Color(0x00000000),
            elevation: 0,
            title: Text('TASK INFO')
        ),
        body: new Container(
            padding: new EdgeInsets.all(20.0),

            child: new Form(
                key: this._formKey,
                child: new ListView(

                  children: taskInfo(context)

                )
            )

        ),
        )
    );
  }


}