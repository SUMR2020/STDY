import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:study/Progress/Subject/ProgressData.dart';
import '../../UpdateApp/Subject/SettingsData.dart';
import '../../HomePage.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';


class ProgressPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProgressPageState();
  }
}


class ProgressPageState extends State<ProgressPage>{
  ProgressData progressData = new ProgressData();
  Future taskProgress;
  Future timeLineProgress;

  var shades = [
    Color(0xFFF48FB1),
    Color(0xFFD81B60),
    Color(0xFF880E4F),
    Color(0xFFAD1457),
    Color(0xFFF06292),
    Color(0xFFC2185B),
    Color(0xFFF50057),
    Color(0xFFE91E63),
    Color(0xFFFF80AB),
    Color(0xFFFF4081)];

  Future _getTasks() async{
    return  await progressData.getTotalProgressData();
  }

  Future _getTimelineProgress() async{
    return await progressData.getTimelineProgressData();
  }


  List<charts.Series<Task,String>>  _pieSeriesData(data, taskType){
    List<Task> totalProgress=[];
    int i = 0;
    for (var item in data[taskType].entries){
      totalProgress.add(new Task(item.key, double.parse(item.value['percent'].toStringAsFixed(1)), shades[i]));
      i++;
    }
    return [new charts.Series(
      data: totalProgress,
      domainFn: (Task task,_)=>task.task,
      measureFn: (Task task,_)=>task.taskvalue,
      colorFn: (Task task,_)=>
          charts.ColorUtil.fromDartColor(task.colorvalue),
      id: 'Daily Task',
      labelAccessorFn: (Task row,_)=>'${row.taskvalue}',
    )];
  }
  Widget makePieChart(Future taskProgress, var taskType){
    return Expanded(
        child: FutureBuilder(
            future: taskProgress,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                return charts.PieChart(
                    _pieSeriesData(snapshot.data, taskType),
                    animate: true,
                    behaviors: [
                      new charts.DatumLegend(
                        outsideJustification: charts.OutsideJustification.start,
                        horizontalFirst: false,
                        desiredMaxRows: 1,
                        cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                        entryTextStyle: charts.TextStyleSpec(
                            color: charts.MaterialPalette.pink.shadeDefault,
                            fontSize: 14 + fontScale
                        ),
                      )
                    ],
                    defaultRenderer: new charts.ArcRendererConfig(
                        arcWidth: 75,
                        arcRendererDecorators: [
                          new charts.ArcLabelDecorator()
                        ]));
              } else {
                return Align(child: CircularProgressIndicator());
              }
            }
        )
    );
  }

  List<charts.Series<Hours,int>> _lineSeriesData(data, taskType){
    var _seriesLineData = List<charts.Series<Hours,int>> ();
    List<Hours> goal = [];
    List<Hours> progress = [];


    for (int i = -6; i < 1; i++) {
      goal.add(Hours(i+7, data[taskType][i.toString()]['totalGoal'].round()));

    }
    for (int i = -6; i < 1; i++) {
      progress.add(Hours(i+7, data[taskType][i.toString()]['totalProgress'].round()));
    }


    _seriesLineData.add(
      charts.Series(
        data: goal,
        domainFn: (Hours hours,_)=>hours.hours,
        measureFn: (Hours hours,_)=>hours.days,
        colorFn: (Hours hours,_)=>
            charts.ColorUtil.fromDartColor(Color(0xFFFDA3A4)),
        id: 'Goal',

      ),
    );

    _seriesLineData.add(
      charts.Series(
        data: progress,
        domainFn: (Hours hours,_)=>hours.hours,
        measureFn: (Hours hours,_)=>hours.days,
        colorFn: (Hours hours,_)=>
            charts.ColorUtil.fromDartColor(Color(0xFFE91E63)),
        id: 'Progress',

      ),
    );
    return _seriesLineData;
  }


  Widget makeLineChart(Future timelineProgress, var taskType, var ylabel){
    return Expanded(
      child: FutureBuilder(
        future: timelineProgress,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            return charts.LineChart(
              _lineSeriesData(snapshot.data, taskType),
              defaultRenderer: new charts.LineRendererConfig(
                  includeArea: true, stacked: true),
              animate : true,
              behaviors: [
                new charts.ChartTitle('Days', behaviorPosition: charts.BehaviorPosition.bottom,
                titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
                new charts.ChartTitle(ylabel, behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification: charts.OutsideJustification.middleDrawArea),

                new charts.SeriesLegend(
                  position: charts.BehaviorPosition.bottom,
                  outsideJustification: charts.OutsideJustification.endDrawArea,
                  horizontalFirst: false,
                  desiredMaxRows: 2,
                  cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                  entryTextStyle: charts.TextStyleSpec(
                      color: charts.MaterialPalette.pink.shadeDefault,
                      fontSize: 14 + fontScale
                  ),
                )
              ],
            );
          } else {
            return Align(child: CircularProgressIndicator());
          }
        }
      )
    );
  }


  @override
  void initState() {
    super.initState();
    taskProgress = _getTasks();
    timeLineProgress = _getTimelineProgress();
  }



  @override
  Widget build(BuildContext context) {
    // displays tabs on the page
    return DefaultTabController(
      length: 6,
      child:Scaffold(
        appBar: new PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: new Container(
            //  color: Colors.green,
            child: new SafeArea(
              child: Column(
                children: <Widget>[
                  new Expanded(child: new Container()),
                  new TabBar(
                    indicatorColor: Theme.of(context).accentColor,
                    tabs: [
                      Tab(icon: Icon(Icons.home,
                        color: Theme.of(context).accentColor,)
                      ),
                      Tab(icon: Icon(Icons.book,
                        color: Theme.of(context).accentColor,)),
                      Tab(icon: Icon(Icons.assignment,
                        color: Theme.of(context).accentColor,)),
                      Tab(icon: Icon(Icons.subtitles,
                        color: Theme.of(context).accentColor,)
                      ),
                      Tab(icon: Icon(Icons.ondemand_video,
                        color: Theme.of(context).accentColor,)
                      ),
                      Tab(icon: Icon(Icons.event_note,
                        color: Theme.of(context).accentColor,)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        //the body contains a list of widgets. each Padding() is a tab, it contains graphs

        body: TabBarView(
            children: [
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                      child: Center(
                          child: Column(
                            children: <Widget>[
                              Text("Current Progress On Your Tasks", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                              SizedBox(height: 10.0,),
                              makePieChart(taskProgress, 'total'),
                              Text("Expected VS. Actual Work Done", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                              makeLineChart(timeLineProgress, 'total', 'Work Total'),
                            ],
                          )
                      )
                  )
              ),

              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                      child: Center(
                          child: Column(
                            children: <Widget>[
                              Text("Current Progress On Your Readings", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                              SizedBox(height: 10.0,),
                              makePieChart(taskProgress, 'reading'),
                              Text("Expected VS. Actual Work Done", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                              makeLineChart(timeLineProgress, 'reading', 'Pages'),
                            ],
                          )
                      )
                  )
              ),

              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text("Current Progress On Your Assignments", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                        SizedBox(height: 10.0,),
                        makePieChart(taskProgress, 'assignment'),
                        Text("Expected VS. Actual Work Done", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                        makeLineChart(timeLineProgress, 'assignment', 'Hours'),
                      ],
                    )
                  )
                )
              ),

              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                      child: Center(
                          child: Column(
                            children: <Widget>[
                              Text("Current Progress On Your Projects", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                              SizedBox(height: 10.0,),
                              makePieChart(taskProgress, 'project'),
                              Text("Expected VS. Actual Work Done", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                              makeLineChart(timeLineProgress, 'project', 'Hours'),
                            ],
                          )
                      )
                  )
              ),

              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                      child: Center(
                          child: Column(
                            children: <Widget>[
                              Text("Current Progress On Your Lectures", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                              SizedBox(height: 10.0,),
                              makePieChart(taskProgress, 'lectures'),
                              Text("Expected VS. Actual Work Done", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                              makeLineChart(timeLineProgress, 'lectures', 'Hours'),
                            ],
                          )
                      )
                  )
              ),

              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                      child: Center(
                          child: Column(
                            children: <Widget>[
                              Text("Current Progress On Your Notes", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                              SizedBox(height: 10.0,),
                              makePieChart(taskProgress, 'notes'),
                              Text("Expected VS. Actual Work Done", style: TextStyle(color: Color(0xFFFDA3A4), fontSize: 14.0 + fontScale)),
                              makeLineChart(timeLineProgress, 'notes', 'Hours'),
                            ],
                          )
                      )
                  )
              ),

            ]
        ),
      ),
    );

  }
}

class Task{
  String task;
  double taskvalue;
  Color colorvalue;
  Task(this.task, this.taskvalue, this.colorvalue);

}

class Hours{
  int hours;
  int days;
  Hours(this.hours, this.days);
}