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

Future<Map<DateTime, List>> getEvents(calendar.CalendarApi events) async {
  final Map<DateTime, List> eventCal = {};
  var calEvents = events.events.list("primary",
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      orderBy: 'startTime',
      singleEvents: true);
  var _events = await calEvents;
  _events.items.forEach((_event) {
    DateTime eventTime = DateTime(
        _event.start.dateTime.year,
        _event.start.dateTime.month,
        _event.start.dateTime.day);
    if (eventCal.containsKey(eventTime)) {
      List<String> DayEvents = (eventCal[DateTime(
          _event.start.dateTime.year,
          _event.start.dateTime.month,
          _event.start.dateTime.day,
          )]);
      DayEvents.add(_event.summary);
      eventCal[eventTime] = DayEvents;
      // eventCal[DateTime(_event.start.dateTime.year, _event.start.dateTime.month, _event.start.dateTime.day, _event.start.dateTime.hour, _event.start.dateTime.minute, _event.start.dateTime.second)] = DayEvents.add(_event.summary);

      //   eventCal.update(eventTime, (value) => (DayEvents.add(_event.summary)));
    } else {
      List<String> DayEvents = [_event.summary];
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

class _MyHomePageState extends State<SchedulePage> {
  DateTime _currentDate = DateTime.now();
  DateTime _currentDate2 = DateTime.now();
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _targetDateTime = DateTime.now();
  Map<DateTime, List> eventCal;
  calendar.CalendarApi events;

  loadEvents() async {
    var eventlist = await gettingCalendar();
    events = eventlist;
    eventCal = await getEvents(events);
    print("Before eventCal");
    _markedDateMap.add(
        new DateTime(2019, 2, 10),
        new Event(
          date: new DateTime(2019, 2, 10),
          title: 'Event 4',
          icon: _eventIcon,
        ));
    eventCal.forEach((k, v) => print(k));
    for (var date in eventCal.keys) {
     for (var i = 0; i < eventCal[date].length; i++) {
        print("add " + eventCal[date][i]);
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
    /// Add more events to _markedDateMap EventList
    // eventCal.forEach((k,v)
//    loadEvents();
//    print ("before adding");
//    for (var date in eventCal.keys) {
//      for (var i = 0; i < eventCal[date].length; i++) {
//        _markedDateMap.add(date, eventCal[date][i]);
//      }
//    }
    super.initState();
  }

  void createCalendar() {
    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      selectedDayButtonColor: stdyPink,
      selectedDayBorderColor: stdyPink,
      todayBorderColor: stdyPink,
      onDayPressed: (DateTime date, List<Event> events) {
        this.setState(() => _currentDate2 = date);
        events.forEach((event) => print(event.title));
      },
      daysHaveCircularBorder: true,
      showOnlyCurrentMonthDate: false,
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
        print('long pressed date $date');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Example Calendar Carousel without header and custom prev & next button
    print(_markedDateMap);
    //   loadEvents().then((response){
//      _calendarCarouselNoHeader = CalendarCarousel<Event>(
//        selectedDayButtonColor: stdyPink,
//        selectedDayBorderColor: stdyPink,
//        todayBorderColor: stdyPink,
//        onDayPressed: (DateTime date, List<Event> events) {
//          this.setState(() => _currentDate2 = date);
//          events.forEach((event) => print(event.title));
//        },
//        daysHaveCircularBorder: true,
//        showOnlyCurrentMonthDate: false,
//        weekendTextStyle: TextStyle(
//          color: Colors.white,
//        ),
//        thisMonthDayBorderColor: Colors.grey,
//
//        weekFormat: false,
//        markedDatesMap: _markedDateMap,
//        height: 420.0,
//        selectedDateTime: _currentDate2,
//        targetDateTime: _targetDateTime,
//        customGridViewPhysics: NeverScrollableScrollPhysics(),
//        markedDateCustomShapeBorder: CircleBorder(
//            side: BorderSide(color: stdyPink)
//        ),
//        markedDateCustomTextStyle: TextStyle(
//          fontSize: 18,
//          color: stdyPink,
//        ),
//        showHeader: false,
//
//
//        weekdayTextStyle: TextStyle(
//          color: Colors.white,
//        ),
//        todayTextStyle: TextStyle(
//          color: Colors.white,
//        ),
//        todayButtonColor: Colors.grey,
//        selectedDayTextStyle: TextStyle(
//          color: Colors.white,
//
//        ),
//        minSelectedDate: _currentDate.subtract(Duration(days: 360)),
//        maxSelectedDate: _currentDate.add(Duration(days: 360)),
//        prevDaysTextStyle: TextStyle(
//          fontSize: 16,
//          color: stdyPink,
//        ),
//        inactiveDaysTextStyle: TextStyle(
//          color: Colors.white,
//          fontSize: 16,
//        ),
//        onCalendarChanged: (DateTime date) {
//          this.setState(() {
//            _targetDateTime = date;
//            _currentMonth = DateFormat.yMMM().format(_targetDateTime);
//          });
//        },
//        onDayLongPressed: (DateTime date) {
//          print('long pressed date $date');
//        },
//      );
    //  });
    print(_markedDateMap);
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
//                FlatButton(
//                  child: Text('PREV'),
//                  onPressed: () {
//                    setState(() {
//                      _targetDateTime = DateTime(
//                          _targetDateTime.year, _targetDateTime.month - 1);
//                      _currentMonth = DateFormat.yMMM().format(_targetDateTime);
//                    });
//                  },
//                ),
//                FlatButton(
//                  child: Text('NEXT'),
//                  onPressed: () {
//                    setState(() {
//                      _targetDateTime = DateTime(
//                          _targetDateTime.year, _targetDateTime.month + 1);
//                      _currentMonth = DateFormat.yMMM().format(_targetDateTime);
//                    });
//                  },
//                )
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder(
                  future: loadEvents(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      createCalendar();
                      print (_calendarCarouselNoHeader.markedDatesMap.getEvents(_currentDate));
                      return _calendarCarouselNoHeader;
                    } else {
                      return new CircularProgressIndicator();
                    }
                  })
              //_calendarCarouselNoHeader,
              ), //
        ],
      ),
    ));
  }
}
