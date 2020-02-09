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


DateTime start = new DateTime.now().subtract(new Duration(days: 30));
DateTime end = new DateTime.now().add(new Duration(days: 30));
Map<DateTime, List> eventCal = {};

Future <bool> _OnStartup;

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
    var summary = ("["+_event.start.dateTime.hour.toString().padLeft(2, "0") +":"+_event.start.dateTime.minute.toString().padLeft(2, "0")+"] " + _event.summary);
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

  _MyHomePageState(){
    _OnStartup = loadEvents();
  }

  DateTime _currentDate = DateTime.now();
  DateTime _currentDate2 = DateTime.now();
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _targetDateTime = DateTime.now();
  Map<DateTime, List> eventCal;
  calendar.CalendarApi events;

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

  CalendarCarousel _calendarCarousel, _calendarCarouselNoHeader;

  @override
  void initState() {
    super.initState();
  }

  void createCalendar() {
    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      selectedDayButtonColor: stdyPink,
      selectedDayBorderColor: stdyPink,
      todayBorderColor: stdyPink,
      onDayPressed: (DateTime date, List<Event> events) {
        if (date != _currentDate2) {
          print("pressed");
          this.setState(() => _currentDate2 = date);
          events.forEach((event) => print(event.title));
        }
      },

      daysHaveCircularBorder: true,
      showOnlyCurrentMonthDate: true,
      weekendTextStyle: TextStyle(
        color: Colors.white,
      ),
      thisMonthDayBorderColor: Colors.grey,
      weekFormat: false,
      markedDatesMap: _markedDateMap,
      height: 420.0,
      selectedDateTime: _currentDate2,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: null,
      isScrollable: false,
      markedDateCustomShapeBorder:
          CircleBorder(side: BorderSide(color: stdyPink)),
      markedDateCustomTextStyle: TextStyle(
        fontSize: 18,
        color: stdyPink,
      ),
      showHeader: false,
      weekdayTextStyle: TextStyle(
        color: Colors.white,
      ),
      todayTextStyle: TextStyle(
        color: Colors.white,
      ),
      todayButtonColor: Colors.grey,
      selectedDayTextStyle: TextStyle(
        color: Colors.white,
      ),
      minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),
      prevDaysTextStyle: TextStyle(
        fontSize: 16,
        color: stdyPink,
      ),
      inactiveDaysTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
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
        String formatDate(DateTime date) => new DateFormat("EEEE, MMM d, yyyy").format(date);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return new SimpleDialog(
              title: Text(formatDate(date)),
              children: <Widget>[
                new Container(
                  height: 300.0,
                  width: 100.0,
                  child: events.isEmpty ? Center(child: Text('No events scheduled')) : new ListView.builder(
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
                      }

                  ))]

                  );

          },
        );
//        showDialog(
//          context: context,
//          builder: (BuildContext context) {
//            // return object of type Dialog
//            return AlertDialog(
//              title: new Text(formatDate(date)),
//              content: ListView.builder(
//                // Let the ListView know how many items it needs to build.
//                itemCount: items.length,
//                // Provide a builder function. This is where the magic happens.
//                // Convert each item into a widget based on the type of item it is.
//                itemBuilder: (context, index) {
//                  final item = items[index];
//
//                  if (item is HeadingItem) {
//                    return ListTile(
//                      title: Text(
//                        item.heading,
//                        style: Theme.of(context).textTheme.headline,
//                      ),
//                    );
//                  } else if (item is MessageItem) {
//                    return ListTile(
//                      title: Text(item.sender),
//                      subtitle: Text(item.body),
//                    );
//                  }
//                },
//              ),
//              actions: <Widget>[
//                // usually buttons at the bottom of the dialog
//                new FlatButton(
//                  child: new Text("Close"),
//                  onPressed: () {
//                    Navigator.of(context).pop();
//                  },
//                ),
//              ],
//            );
//          },
//        );
        print('long pressed date $date');
      },
      // staticSixWeekFormat: true,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: _calendarCarousel,
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
                  _currentMonth,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
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
                      createCalendar();
                      return _calendarCarouselNoHeader;
                    }  else {
                        return CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(stdyPink),
                        );
                    }
                  })
              //_calendarCarouselNoHeader,
              ), //
        ],
      ),
    ));
  }
}
