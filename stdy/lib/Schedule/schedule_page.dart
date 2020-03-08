import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:study/Schedule/task_manager.dart';
import '../home_widget.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:intl/intl.dart' show DateFormat;
import '../main.dart';
import 'package:provider/provider.dart';
import '../Settings/theme.dart';
import 'selection_page.dart';
import 'CustomForm.dart';

DateTime today = new DateTime.now();

class SchedulePage extends StatefulWidget {
  _SchedulePageState createState() => new _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  _SchedulePageState() {
    _onStartup = taskManager.loadEvents();
    _tasksLoaded = taskManager.getTasks();
    _doneTasksLoaded = taskManager.getDoneTasks();
  }
  TaskManager taskManager = new TaskManager();
  Future<bool> _onStartup;
  Future<bool> _tasksLoaded;
  Future<bool> _doneTasksLoaded;
  bool isSwitched = true;
  DateTime _currentDate = DateTime.now();
  DateTime _currentDate2 = DateTime.now();
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _targetDateTime = DateTime.now();

  IconData getIcon(String taskType) {
    if (taskType == "reading") return Icons.book;
    if (taskType == "assignment") return Icons.assignment;
    if (taskType == "project") return Icons.subtitles;
    if (taskType == "lectures") return Icons.ondemand_video;
    if (taskType == "notes") return Icons.event_note;
    return null;
  }

  void updatingCurrentDay() async{
    today = await taskManager.grades.updateDay(today);
  }


  String getTypeString(String taskType, String time){
    if (taskType == "reading") return (time + " pages");

    return (time.toString() + " hours");
  }

  Widget _listDoneTaskView() {
    print (taskManager.todayDoneTasks.length);
    return new Container(
        height: 100.0,
        child: new ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: taskManager.todayDoneTasks.length,
          itemBuilder: (context, index) {

            return new GestureDetector(
                onTap: () {
                },
                child: new Card( //                           <-- Card widget

                  child: ListTile(
                    leading: Icon(getIcon(taskManager.todayDoneTasks[index].type)),
                    title: Text(taskManager.todayDoneTasks[index].onlyCourse+": "+taskManager.todayDoneTasks[index].name),
                  ),

                ));

          },
        ));
  }

  CalendarCarousel  _calendarCarouselNoHeader;

  Widget _listTaskView() {
    String done;
    return new Container(
        height: 100.0,
        child: new ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: taskManager.todayTasks.length,
          itemBuilder: (context, index) {

            return new GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Form(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    onChanged: (text) {
                                      done = text;
                                    },
                                    decoration: new InputDecoration(
                                      hintText: 'How much did you complete today?',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RaisedButton(
                                    child: Text("Submit"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      if (isNumeric(done)) {
                                        taskManager.grades.updateProgressandDaily(
                                            taskManager.todayTasks[index].id
                                            , taskManager.todayTasks[index].course, done);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context){
                                              return Home();
                                            }
                                          )
                                        );
                                      }
                                      else{
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Please select a valid number.'),
                                              );
                                            });
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
            child: new Card( //                           <-- Card widget

              child: ListTile(
                leading: Icon(getIcon(taskManager.todayTasks[index].type)),
                title: Text(taskManager.todayTasks[index].onlyCourse+ ": "+taskManager.todayTasks[index].name),
                trailing: Text(getTypeString(taskManager.todayTasks[index].type, taskManager.todayTasks[index].time)),
              ),

            ));

          },
        ));
  }


  void createCalendar(ThemeChanger theme) {
    var colour;
    var colourweekend;
    if (theme.getTheme() == themeStyleData[ThemeStyle.Dark]) {
      colour = Colors.white;
      colourweekend = Colors.white;
    }

    if (theme.getTheme() == themeStyleData[ThemeStyle.DarkOLED]) {
      colour = Colors.white;
      colourweekend = Colors.white;
    }

    if (theme.getTheme() == themeStyleData[ThemeStyle.Light]) {
      colour = stdyPink;
      colourweekend = Colors.black;
    }

    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      selectedDayButtonColor: stdyPink,
      selectedDayBorderColor: stdyPink,
      todayBorderColor: Colors.blueGrey,
      onDayPressed: (DateTime date, List<Event> events) {
        if (date != _currentDate2) {
          print("pressed");
          this.setState(() => _currentDate2 = date);
          events.forEach((event) => print(event.title));
        }
      },
      daysTextStyle: new TextStyle(color: colourweekend,
      fontSize: 14 + fontScale.toDouble()),
      inactiveDaysTextStyle: TextStyle(
        fontSize: 14 + fontScale.toDouble(),
        color: colourweekend,
      ),
      markedDateWidget: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.0),
        color: stdyPink,
        height: 4.0,
        width: 4.0,
      ),
      daysHaveCircularBorder: true,
      showOnlyCurrentMonthDate: true,
      weekendTextStyle: TextStyle(
        fontSize: 14 + fontScale.toDouble(),
        color: colourweekend,
      ),
      thisMonthDayBorderColor: Colors.grey,
      weekFormat: false,
      markedDatesMap: taskManager.markedDateMap,

      height: 300.0,

      selectedDateTime: _currentDate2,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: null,
      isScrollable: false,
      markedDateCustomShapeBorder:
          CircleBorder(side: BorderSide(color: stdyPink)),
      markedDateCustomTextStyle: TextStyle(
        fontSize: 18 + fontScale.toDouble(),
        color: stdyPink,
      ),
      showHeader: false,
      weekdayTextStyle: TextStyle(
        fontSize: 14 + fontScale.toDouble(),
        color: colourweekend,
      ),
      todayTextStyle: TextStyle(
        fontSize: 14 + fontScale.toDouble(),
        color: colour,
      ),
      todayButtonColor: Colors.blueGrey,
      selectedDayTextStyle: TextStyle(
        fontSize: 14 + fontScale.toDouble(),
        color: colourweekend,
      ),
      minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),
      prevDaysTextStyle: TextStyle(
        fontSize: 16 + fontScale.toDouble(),
        color: stdyPink,
      ),
      onCalendarChanged: (DateTime date) {
        this.setState(() {
          _targetDateTime = date;
          _currentMonth = DateFormat.yMMM().format(_targetDateTime);
        });
      },
      onDayLongPressed: (DateTime date) {
        var events = taskManager.markedDateMap.getEvents(date);
        this.setState(() => _currentDate2 = date);
        events.forEach((event) => print(event.title));
        String formatDate(DateTime date) =>
            new DateFormat("EEEE, MMM d, yyyy").format(date);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return new SimpleDialog(
                title: Text(formatDate(date)),
                children: <Widget>[
                  new Container(
                      height: 300.0,
                      width: 100.0,
                      child: events.isEmpty
                          ? Center(child: Text('No events scheduled'))
                          : new ListView.builder(
                              // Let the ListView know how many items it needs to build.
                              itemCount: events.length,
                              // Provide a builder function. This is where the magic happens.
                              // Convert each item into a widget based on the type of item it is.
                              itemBuilder: (context, index) {
                                final item = events[index];
                                return ListTile(
                                  title: Text(item.title),
                                  // subtitle: Text(item.body),
                                );
                              }))
                ]);
          },
        );
        print('long pressed date $date');
      },
    );
  }

  String getListViewTitle(){
    if (isSwitched) return "TO DO TODAY";
    return "DONE TASKS";
  }

  Widget getCurrentContainer(){
    if (isSwitched){
      return new Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          height: 300,
          child: FutureBuilder(
              future: _tasksLoaded,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return _listTaskView();
                } else {
                  return SizedBox.shrink();
                }
              }));
    } else { return new Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        height: 300,
        child: FutureBuilder(
            future: _doneTasksLoaded,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return _listDoneTaskView();
              } else {
                return SizedBox.shrink();
              }
            }));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    updatingCurrentDay();
    return new Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SelectionPage()),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: stdyPink,
          shape: CircleBorder(),
        ),
        body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              top: 30.0,
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: new Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  _currentMonth.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0 + fontScale,
                  ),
                )),
//
              ],
            ),
          ),

          Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder(
                  future: _onStartup,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      createCalendar(theme);
                      return _calendarCarouselNoHeader;
                    } else {
                      return CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(stdyPink),
                      );
                    }
                  })
              //_calendarCarouselNoHeader,
              ),

          Container(
            margin: EdgeInsets.only(
              top: 30.0,
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),

            child: new Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                      getListViewTitle(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0 + fontScale,
                      ),
                    )),
                Switch(
                  activeColor: Theme.of(context).primaryColor,
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                ),
              ],
            ),
          ),
          getCurrentContainer(),
        ],
      ),
    ));

  }
}