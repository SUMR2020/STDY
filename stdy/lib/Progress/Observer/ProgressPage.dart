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

//factory class that draws line graphs

//class LineChartFactory {
//  LineChartFactory();
//
//  Widget makeLineChart(List<charts.Series<Hours,int>> _seriesLineData){
//    return Expanded(
//      child: charts.LineChart(
//        _seriesLineData,
//        defaultRenderer: new charts.LineRendererConfig(
//            includeArea: false, stacked: true),
//        animate : true,
//      ),
//    );
//  }
//}
//


class ProgressPageState extends State<ProgressPage>{
  List<charts.Series<Task,String>> _seriesPieData;
  List<charts.Series<Task,String>> _seriesPieDataB;
  List<charts.Series<Hours,int>> _seriesLineData;
  //List<charts.Series<Hours,int>> _seriesLineDataB;

  ProgressData progressData = new ProgressData();
  Future taskProgress;

  Future _getTasks() async{
    print("getTasks called in page");
    return  await progressData.getTotalProgressDatat();
  }

  List<charts.Series<Task,String>>  _seriesData(data, taskType){
    List<Task> totalProgress=[];
    data[taskType].forEach((k, v) => totalProgress.add(new Task('$k', double.parse(v['percent'].toStringAsFixed(1)), Color(0xFFFDA3A4) )));

    return [new charts.Series(
      data: totalProgress,
      domainFn: (Task task,_)=>task.task,
      measureFn: (Task task,_)=>task.taskvalue,
//        colorFn: (Task task,_)=>
//            charts.ColorUtil.fromDartColor(task.colorvalue),
      id: 'Daily Task',
      labelAccessorFn: (Task row,_)=>'${row.taskvalue}',
    )];
  }
  Widget makePieChart(Future taskProgress, var taskType){
    return Expanded(
        child: FutureBuilder(
            future: taskProgress,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                print(snapshot.data.toString());
                return charts.PieChart(
                    _seriesData(snapshot.data, taskType),
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

  Widget makeLineChart(List<charts.Series<Hours,int>> _seriesLineData){
    return Expanded(
      child: charts.LineChart(
        _seriesLineData,
        defaultRenderer: new charts.LineRendererConfig(
            includeArea: false, stacked: true),
        animate : true,
      ),
    );
  }




  //function to generate data to be passed into the graph drawing methods


  _generateData() {

    var pieDataB=[
      new Task('Project 1', 15.0, Color(0xFFFDA3A4) ),
      new Task('Project 2', 40.0, Color(0xFFF06292) ),
      new Task('Project 3', 45.0 , Color(0xFFE91E63)),

    ];

    var actual=[
      new Hours(0,11),
      new Hours(1,12),
      new Hours(2,2),
      new Hours(3,4),

    ];

    var expected=[
      new Hours(0,10),
      new Hours(1,11),
      new Hours(2,5),
      new Hours(3,6),
    ];


    _seriesPieData.add(
      charts.Series(
        data: pieDataB,
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
        data: actual,
        domainFn: (Hours hours,_)=>hours.hours,
        measureFn: (Hours hours,_)=>hours.days,
        colorFn: (Hours hours,_)=>
            charts.ColorUtil.fromDartColor(Color(0xFFFDA3A4)),
        id: 'Hours',

      ),
    );

    _seriesLineData.add(
      charts.Series(
        data: expected,
        domainFn: (Hours hours,_)=>hours.hours,
        measureFn: (Hours hours,_)=>hours.days,
        colorFn: (Hours hours,_)=>
            charts.ColorUtil.fromDartColor(Color(0xFFE91E63)),
        id: 'Hours',

      ),
    );

  }


  @override
  void initState() {
    super.initState();
    _seriesPieData = List<charts.Series<Task,String>>();
    _seriesPieDataB = List<charts.Series<Task,String>>();
    _seriesLineData = List<charts.Series<Hours,int>> ();
    //_seriesLineDataB = List<charts.Series<Hours,int>> ();
    _generateData();
    taskProgress = _getTasks();
  }



  @override
  Widget build(BuildContext context) {
//    PieChartFactory chartFactory = new PieChartFactory();
//    LineChartFactory linechartFactory =  new  LineChartFactory();

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
                      Tab(icon: Icon(Icons.book,
                        color: Theme.of(context).accentColor,)
                      ),
                      Tab(icon: Icon(Icons.assignment,
                        color: Theme.of(context).accentColor,)),
                      Tab(icon: Icon(Icons.note,
                        color: Theme.of(context).accentColor,)),
                      Tab(icon: Icon(Icons.event_note,
                        color: Theme.of(context).accentColor,)
                      ),
                      Tab(icon: Icon(Icons.pie_chart,
                        color: Theme.of(context).accentColor,)
                      ),
                      Tab(icon: Icon(Icons.blur_linear,
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
                              makePieChart(taskProgress, 'total'),
                              makeLineChart(_seriesLineData),
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
                              makePieChart(taskProgress, 'reading'),
                              makeLineChart(_seriesLineData),
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
                        makePieChart(taskProgress, 'assignment'),
                        makeLineChart(_seriesLineData),
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
                              makePieChart(taskProgress, 'project'),
                              makeLineChart(_seriesLineData),
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
                              makePieChart(taskProgress, 'lectures'),
                              makeLineChart(_seriesLineData),
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
                              makePieChart(taskProgress, 'notes'),
                              makeLineChart(_seriesLineData),
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
//gonna need time as a thingy here
  Task(this.task, this.taskvalue, this.colorvalue);

}

class Hours{
  int hours;
  int days;

  Hours(this.hours, this.days);
}