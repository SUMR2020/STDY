import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:study/GoogleAPI/Calendar/CalendarAPI.dart';
import 'package:study/Schedule/Subject/TaskData.dart';
import '../../HomePage.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import '../../UpdateApp/Subject/SettingsData.dart';
import 'TaskSelectionPage.dart';
import '../Helper/Task.dart';
import '../Subject/CalendarData.dart';
/*
SchedulePage
This is the underlying page we are building on.

_SchedulePageState
Class that the display of viewing the calendar, to do list, and done tasks list
this is an extension of the SchedulePage, as it is a state of the SchedulePage.
     today: current date
     calendarManager: the DAO object to access the calendar API
     taskManager: the DAO object to access the database
     _onStartup: boolean for if events have been loaded
     _tasksLoaded: boolean for if tasks have been loaded
     _doneTasksLoaded: boolean for if done tasks have been loaded
     isSwitched: boolean for if to display current or done tasks
     _currentDate: the current date, used for calendar
     _currentMonth: current month, used for calendar
     _targetDateTime: current selected date, used for calendar
*/

class SchedulePage extends StatefulWidget {
  _SchedulePageState createState() => new _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>{
   _SchedulePageState() {
    print("opened schedule");
    _onStartup = calendarManager.loadEvents();
    _tasksLoaded = taskManager.getTasks();
    _doneTasksLoaded = taskManager.getDoneTasks();
  }
  CalendarData calendarManager = new CalendarData();
  TaskData taskManager = new TaskData();
  Future<bool> _onStartup;
  Future<bool> _tasksLoaded;
  Future<bool> _doneTasksLoaded;
  bool isSwitched = true;
  DateTime _currentDate = DateTime.now();
  DateTime _currentDate2 = DateTime.now();
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _targetDateTime = DateTime.now();

  // getting an icon based off of the type of task
  IconData getIcon(String taskType) {
    if (taskType == "reading") return Icons.book;
    if (taskType == "assignment") return Icons.assignment;
    if (taskType == "project") return Icons.subtitles;
    if (taskType == "lectures") return Icons.ondemand_video;
    if (taskType == "notes") return Icons.event_note;
    return null;
  }

  // updating the task info if the day changes
  void updatingCurrentDay() async{
    await taskManager.updateDay();
  }

  // getting the string for amount to do based off of task type
  String getTypeString(String taskType, String time){
    if (taskType == "reading") return (time + " pages");
    return (time.toString() + " hours");
  }

  // the list view for done tasks, does not include amount
  Widget _listDoneTaskView() {
    print (taskManager.todayDoneTasks.length);
    return new Container(
        height: 100.0,
        child: new ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: taskManager.todayDoneTasks.length(),
          itemBuilder: (context, index) {

            return new GestureDetector(
                onTap: () {
                },
                child: new Card( //                           <-- Card widget

                  child: ListTile(
                    leading: Icon(getIcon(taskManager.todayDoneTasks.get(index).type)),
                    title: Text(taskManager.todayDoneTasks.get(index).onlyCourse+": "+taskManager.todayDoneTasks.get(index).name),
                  ),

                ));

          },
        ));
  }

  CalendarCarousel  _calendarCarouselNoHeader;

  // listview for current tasks, have amount and can update the amount done
  Widget _listTaskView() {
    String done;
    return new Container(
        height: 100.0,
        child: new ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: taskManager.todayTasks.length(),
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
                                      if (Task.Empty().isNumeric(done)) {
                                        taskManager.updatingProgress(
                                            taskManager.todayTasks.get(index).id
                                            , taskManager.todayTasks.get(index).course, done);
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
                leading: Icon(getIcon(taskManager.todayTasks.get(index).type)),
                title: Text(taskManager.todayTasks.get(index).onlyCourse+ ": "+taskManager.todayTasks.get(index).name),
                trailing: Text(getTypeString(taskManager.todayTasks.get(index).type, taskManager.todayTasks.get(index).time)),
              ),

            ));

          },
        ));
  }


  //creating a calendar
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
      colour = Theme.of(context).primaryColor;
      colourweekend = Colors.black;
    }

    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      selectedDayButtonColor: Theme.of(context).primaryColor,
      selectedDayBorderColor: Theme.of(context).primaryColor,
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
        color: Theme.of(context).primaryColor,
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
      markedDatesMap: calendarManager.markedDateMap,

      height: 300.0,

      selectedDateTime: _currentDate2,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: null,
      isScrollable: false,
      markedDateCustomShapeBorder:
          CircleBorder(side: BorderSide(color: Theme.of(context).primaryColor)),
      markedDateCustomTextStyle: TextStyle(
        fontSize: 18 + fontScale.toDouble(),
        color: Theme.of(context).primaryColor,
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
        color: Theme.of(context).primaryColor,
      ),
      onCalendarChanged: (DateTime date) {
        this.setState(() {
          _targetDateTime = date;
          _currentMonth = DateFormat.yMMM().format(_targetDateTime);
        });
      },
      onDayLongPressed: (DateTime date) {
        var events = calendarManager.markedDateMap.getEvents(date);
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

  // getting the title of the current listview
  String getListViewTitle(){
    if (isSwitched) return "TO DO TODAY";
    return "DONE TASKS";
  }

  // getting the container of the current listview
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
    taskManager.printTasks();
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
          backgroundColor: Theme.of(context).primaryColor,
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
                        valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
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
