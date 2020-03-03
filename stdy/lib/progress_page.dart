import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:study/main.dart';
import 'home_widget.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class progressPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return progressPageState();
  }
}

class progressPageState extends State<progressPage>{

  List<charts.Series<Task,String>> _seriesPieData;
  List<charts.Series<Task,String>> _seriesPieDataB;
  List<charts.Series<Hours,int>> _seriesLineData;

    _generateData(){

      var pieData=[
        new Task('Assignment 1', 25.0, stdyPink ),
        new Task('Assignment 2', 25.0, Color(0xFFF06292) ),
        new Task('Assignment 3', 50.0 , Color(0xFFE91E63)),

      ];

      var pieDataB=[
        new Task('Project 1', 15.0, stdyPink ),
        new Task('Project 2', 40.0, Color(0xFFF06292) ),
        new Task('Project 3', 45.0 , Color(0xFFE91E63)),

      ];

      var lineData=[
        new Hours(1,1),
        new Hours(3,7),
        new Hours(5,2),
        new Hours(9,4),

      ];


      _seriesPieData.add(
        charts.Series(
          data: pieData,
          domainFn: (Task task,_)=>task.task,
          measureFn: (Task task,_)=>task.taskvalue,
          colorFn: (Task task,_)=>
              charts.ColorUtil.fromDartColor(task.colorvalue),
              id: 'Daily Task',
          labelAccessorFn: (Task row,_)=>'${row.taskvalue}',

        ),
      );

      _seriesPieDataB.add(
        charts.Series(
          data: pieDataB,
          domainFn: (Task task,_)=>task.task,
          measureFn: (Task task,_)=>task.taskvalue,
          colorFn: (Task task,_)=>
              charts.ColorUtil.fromDartColor(task.colorvalue),
          id: 'Daily Task B',
          labelAccessorFn: (Task row,_)=>'${row.taskvalue}',

        ),
      );

      _seriesLineData.add(
        charts.Series(
          data: lineData,
          domainFn: (Hours hours,_)=>hours.hours,
          measureFn: (Hours hours,_)=>hours.days,
          colorFn: (Hours hours,_)=>
              charts.ColorUtil.fromDartColor(stdyPink),
          id: 'Hours',

        ),
      );

    }

  @override
  void initState(){
    super.initState();
    _seriesPieData = List<charts.Series<Task,String>>();
    _seriesPieDataB = List<charts.Series<Task,String>>();
    _seriesLineData = List<charts.Series<Hours,int>> ();
    _generateData();
  }

 // progressPageState(){}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (
       // children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: charts.PieChart(
                        _seriesPieData,
                        animate : true,
                        behaviors: [
                          new charts.DatumLegend(
                            outsideJustification: charts.OutsideJustification.start,
                            horizontalFirst: false,
                            desiredMaxRows: 1,
                            cellPadding: new EdgeInsets.only(right:4.0, bottom:4.0),
                            entryTextStyle: charts.TextStyleSpec(
                              color: charts.MaterialPalette.pink.shadeDefault,
                              fontSize: 14 + fontScale
                            ),
                          )
                        ],
                        defaultRenderer: new charts.ArcRendererConfig(
                          arcWidth: 50,
                          arcRendererDecorators: [
                            new charts.ArcLabelDecorator(
                              labelPosition: charts.ArcLabelPosition.inside)
                          ])),
                    ),

                    Expanded(
                      child: charts.PieChart(
                          _seriesPieDataB,
                          animate : true,
                          behaviors: [
                            new charts.DatumLegend(
                              outsideJustification: charts.OutsideJustification.start,
                              horizontalFirst: false,
                              desiredMaxRows: 1,
                              cellPadding: new EdgeInsets.only(right:4.0, bottom:4.0),
                              entryTextStyle: charts.TextStyleSpec(
                                  color: charts.MaterialPalette.pink.shadeDefault,
                                  fontSize: 14 + fontScale
                              ),
                            )
                          ],
                          defaultRenderer: new charts.ArcRendererConfig(
                              arcWidth: 50,
                              arcRendererDecorators: [
                                new charts.ArcLabelDecorator(
                                    labelPosition: charts.ArcLabelPosition.inside)
                              ])),
                    ),

                    Expanded(
                      child: charts.LineChart(
                          _seriesLineData,
                          animate : false,
                    )
                    )
                  ],
                )
              )
            )
          )
        //]
      ),
            );

  }
}

class Task{
  String task;
  double taskvalue;
  Color colorvalue;
//gonna need time as a thingy here
  Task(this.task, this.taskvalue, this.colorvalue);

}

class Hours{
  int hours;
  int days;

  Hours(this.hours, this.days);
}