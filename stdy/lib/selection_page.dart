import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:study/CustomForm.dart';
import 'package:study/main.dart';
import 'package:validate/validate.dart';
import 'CustomForm.dart';

class SelectionPage extends StatefulWidget {
  String taskType;
  @override
  State<StatefulWidget> createState() => new _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  List<String> tasks = ["READING", "ASSIGNMENT", "PROJECT", "LECTURES", "NOTES"];
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
      ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext context, int index) {
          return new GestureDetector(
            onTap: () {
              print (tasks[index]);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  LoginPage(tasks[index], index),
              ));
            },
            child: Container(
                height: 45.0,
                decoration: BoxDecoration(),
                child: new Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Container(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                             tasks[index],
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 20.0),
                              maxLines: 1,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ),
          );
        },
      ),
    );
  }
}