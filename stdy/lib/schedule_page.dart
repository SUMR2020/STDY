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

bool initial = false;

DateTime start = new DateTime.now().subtract(new Duration(days: 30));
DateTime end = new DateTime.now().add(new Duration(days: 30));
Map<DateTime, List> eventCal = {};

Future <bool> _OnStartup;

Future<Map<DateTime, List>> getEvents(calendar.CalendarApi events) async {
  if (initial == true) {
    print("in init");
    start = new DateTime.now().subtract(new Duration(days: 2));
    end = new DateTime.now().add(new Duration(days: 2));
  }
  var calEvents = events.events.list("primary",
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      orderBy: 'startTime',
      singleEvents: true);
  var _events = await calEvents;
  if (initial == false) {
    initial = true;
  }
  _events.items.forEach((_event) {
    DateTime eventTime = DateTime(_event.start.dateTime.year,
        _event.start.dateTime.month, _event.start.dateTime.day);
    if (eventCal.containsKey(eventTime)) {
      List<String> DayEvents = (eventCal[DateTime(
        _event.start.dateTime.year,
        _event.start.dateTime.month,
        _event.start.dateTime.day,
      )]);
      if ((DayEvents.contains(_event.summary)) == false) {
        DayEvents.add(_event.summary);
        print("Added: " + _event.summary);
        eventCal[eventTime] = DayEvents;
      }
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
