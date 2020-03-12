import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'home_widget.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'main.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'bloc/theme.dart';
import 'selection_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'grades/grades_data.dart';
import 'CustomForm.dart';

DateTime start = new DateTime.now().subtract(new Duration(days: 30));
DateTime end = new DateTime.now().add(new Duration(days: 30));
DateTime today = new DateTime.now();
Map<DateTime, List> eventCal = {};

Future<bool> _OnStartup;
Future<bool> _tasksLoaded;
Future<bool> _doneTasksLoaded;
class Task {
  String type;
  String name;

  String time;
  String id;
  String course;
  Task(String t, String n, String ti, String i, String c) {
    type = t;
    name = n;
    time = ti;
    id = i;
    course = c;
  }
}

Future<Map<DateTime, List>> getEvents(calendar.CalendarApi events) async {
  var calEvents = events.events.list("primary",
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      orderBy: 'startTime',
      singleEvents: true);
  var _events = await calEvents;

  _events.items.forEach((_event) {
    DateTime eventTime = DateTime(_event.start.dateTime.year,
        _event.start.dateTime.month, _event.start.dateTime.day);
    var summary = ("[" +
        _event.start.dateTime.hour.toString().padLeft(2, "0") +
        ":" +
        _event.start.dateTime.minute.toString().padLeft(2, "0") +
        "] " +
        _event.summary);
    if (eventCal.containsKey(eventTime)) {
      List<String> DayEvents = (eventCal[DateTime(
        _event.start.dateTime.year,
        _event.start.dateTime.month,
        _event.start.dateTime.day,
      )]);
      if ((DayEvents.contains(_event.summary)) == false) {
        DayEvents.add(summary);
        print("Added: " + summary);
        eventCal[eventTime] = DayEvents;
      }
    } else {
      print("Added: " + summary);
      List<String> DayEvents = [summary];
      eventCal[(eventTime)] = DayEvents;
    }
  });
  return eventCal;
}

class SchedulePage extends StatefulWidget {
  SchedulePage({Key key, @required this.onSubmit}) : super(key: key);

  final VoidCallback onSubmit;
  static final TextEditingController _grade = new TextEditingController();

  String get grade => _grade.text;

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new TextField(
          controller: _grade,
          decoration: new InputDecoration(hintText: "Schedule"),
        ),
      ],
    );
  }

  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  _MyHomePageState() {
    _OnStartup = loadEvents();
    _tasksLoaded = getTasks();
    _doneTasksLoaded = getDoneTasks();
  }
  List<DocumentSnapshot> taskDocs;
  List<Task> todayTasks = new List<Task>();
  List<Task> todayDoneTasks = new List<Task>();
  GradeData grades = new GradeData();


  DateTime _currentDate = DateTime.now();
  DateTime _currentDate2 = DateTime.now();
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _targetDateTime = DateTime.now();
  Map<DateTime, List> eventCal;
  calendar.CalendarApi events;

  Future<bool> getTasks() async {
    taskDocs = await grades.getTasks();
    for (DocumentSnapshot task in taskDocs) {
    var dates = (task.data['dates']);
    List<DateTime> datesObjs = new List<DateTime>();

    for (Timestamp t in dates){
      DateTime date = (t.toDate());
      datesObjs.add(DateTime(date.year, date.month, date.day));
    }
    DateTime today = DateTime.now();
    if (datesObjs.contains(DateTime(today.year, today.month, today.day))) {
      Task t = new Task(task.data["type"], task.data["name"],task.data["today"], task.data["id"],task.data["course"]);
      todayTasks.add(t);

    }
    }
    return true;
  }

  Future<bool> getDoneTasks() async {
    taskDocs = await grades.getTasks();
    for (DocumentSnapshot task in taskDocs) {
      var dates = (task.data['done']);
      List<DateTime> datesObjs = new List<DateTime>();
      for (Timestamp t in dates){
        DateTime date = (t.toDate());
        datesObjs.add(DateTime(date.year, date.month, date.day));
      }
      DateTime today = DateTime.now();
      if (datesObjs.contains(DateTime(today.year, today.month, today.day))) {
        Task t = new Task(task.data["type"], task.data["name"],task.data["today"], task.data["id"],task.data["course"]);
        todayDoneTasks.add(t);

      }
    }
    return true;
  }

  bool contains(Event i) {
    List events = _markedDateMap.getEvents(i.date);
    for (Event e in events) {
      if (e == i) {
        return true;
      }
    }
    return false;
  }

  Future<bool> loadEvents() async {
    events = await gettingCalendar();
    eventCal = await getEvents(events);
    var dates = eventCal.keys;
    var date;
    for (int i = 0; i < dates.length; i++) {
      date = dates.elementAt(i);
      for (var i = 0; i < eventCal[date].length; i++) {
        Event x = new Event(
          date: date,
          title: eventCal[date][i],
          icon: _eventIcon,
        );
        if (!contains(x)) {
          _markedDateMap.add(
              date,
              new Event(
                date: date,
                title: eventCal[date][i],
                icon: _eventIcon,
              ));
        }
      }
    }
    return (true);
  }

  IconData getIcon(String taskType) {
    if (taskType == "reading") return Icons.book;
    if (taskType == "assignment") return Icons.assignment;
    if (taskType == "project") return Icons.subtitles;
    if (taskType == "lectures") return Icons.ondemand_video;
    if (taskType == "notes") return Icons.event_note;
  }

  void updatingCurrentDay() async{
    today = await grades.updateDay(today);
  }


  String getTypeString(String taskType, String time){
    if (taskType == "reading") return (time + " pages");

    return (time.toString() + " hours");
  }

  Widget _listDoneTaskView() {
    print (todayDoneTasks.length);
    return new Container(
        height: 100.0,
        child: new ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: todayDoneTasks.length,
          itemBuilder: (context, index) {

            return new GestureDetector(
                onTap: () {
                },
                child: new Card( //                           <-- Card widget

                  child: ListTile(
                    leading: Icon(getIcon(todayDoneTasks[index].type)),
                    title: Text(todayDoneTasks[index].name),
                  ),

                ));

          },
        ));
  }

  Widget _listTaskView() {
    String done;
    return new Container(
        height: 100.0,
        child: new ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: todayTasks.length,
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
                                        grades.updateProgressandDaily(
                                            todayTasks[index].id
                                            , todayTasks[index].course, done);
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
                leading: Icon(getIcon(todayTasks[index].type)),
                title: Text(todayTasks[index].name),
                trailing: Text(getTypeString(todayTasks[index].type, todayTasks[index].time)),
              ),

            ));

          },
        ));
  }

  static Widget _eventIcon = new Container(
    decoration: new BoxDecoration(
        color: stdyPink,
        borderRadius: BorderRadius.all(Radius.circular(1000)),
        border: Border.all(color: stdyPink, width: 2.0)),
    child: new Icon(
      Icons.person,
      color: stdyPink,
    ),
  );

  EventList<Event> _markedDateMap = new EventList<Event>();

  CalendarCarousel  _calendarCarouselNoHeader;

  @override
  void initState() {
    super.initState();
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
      markedDatesMap: _markedDateMap,

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
        var events = _markedDateMap.getEvents(date);
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
                  future: _OnStartup,
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
                      "TO DO TODAY",
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
                  future: _tasksLoaded,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return _listTaskView();
                    } else {
                      return SizedBox.shrink();
                    }
                  })),
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
                      "DONE TASKS",
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
                  future: _doneTasksLoaded,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return _listDoneTaskView();
                    } else {
                      return SizedBox.shrink();
                    }
                  }))
          //
        ],
      ),
    ));

  }
}
