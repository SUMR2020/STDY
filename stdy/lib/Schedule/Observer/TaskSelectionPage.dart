import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:study/Schedule/Observer/CurrTaskFormPage.dart';
import '../../UpdateApp/Subject/Theme.dart';
import 'CurrTaskFormPage.dart';

class SelectionPage extends StatefulWidget {
  String taskType;
  @override
  State<StatefulWidget> createState() => new _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  List<String> tasks = ["READING", "ASSIGNMENT", "PROJECT", "LECTURES", "NOTES"];
  List<IconData> icons = [Icons.book, Icons.assignment, Icons.subtitles, Icons.ondemand_video, Icons.event_note];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text('SELECT TYPE OF TASK')
      ),
      body:
      new ListView.builder(
          itemCount: tasks == null ? 0 : tasks.length,
          itemBuilder: (BuildContext context, int index) {
            return new GestureDetector( //You need to make my child interactive
              onTap: () {
              print (tasks[index]);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  CurrTaskFormPage(tasks[index], index),
              ));
            },
              child: new Card( //I
                child: ListTile(
                  leading: Icon(icons[index]),
                  title: Text(tasks[index], style: TextStyle(fontSize: 20 + fontScale.toDouble()),),
                ),// am the clickable child
                ),
            );
          }),
    );
  }
}