import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'home_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;


Future<Map<DateTime, List>> getEvents (calendar.CalendarApi events) async{
  final Map<DateTime, List> eventCal ={};
  var calEvents = events.events.list("primary", timeMin: start.toUtc(), timeMax: end.toUtc(), orderBy: 'startTime', singleEvents: true);
  var _events = await calEvents;
  _events.items.forEach((_event) {
    DateTime eventTime = DateTime(_event.start.dateTime.year, _event.start.dateTime.month, _event.start.dateTime.day, _event.start.dateTime.hour, _event.start.dateTime.minute, _event.start.dateTime.second);
    if (eventCal.containsKey(eventTime)){
      List<String> DayEvents = (eventCal[DateTime(_event.start.dateTime.year, _event.start.dateTime.month, _event.start.dateTime.day, _event.start.dateTime.hour, _event.start.dateTime.minute, _event.start.dateTime.second)]);
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

class SchedulePage extends StatelessWidget {

   SchedulePage ({
    Key key,
    @required this.onSubmit, @required this.eventssync

  }): super(key: key);

  Future<calendar.CalendarApi> events;
  calendar.CalendarApi eventsCurrent;
  Map<DateTime, List> eventCal;
  calendar.CalendarApi eventssync;
  final VoidCallback onSubmit;


  static final TextEditingController _grade = new TextEditingController();
  String get grade => _grade.text;

  void loadData() async {
    var eventlist = await gettingCalendar();
    eventssync = eventlist;
    eventCal = await getEvents(eventssync);
    print ("Before eventCal");
    eventCal.forEach((k,v) => print(k));

    print ("After eventCal");
  }
  @override
  Widget build(BuildContext context){
    loadData();

    return new Column(
      children: <Widget>[
        new TextField(controller: _grade, decoration: new InputDecoration(hintText: "Schedule"), ),
      ],
    );

  }
}

