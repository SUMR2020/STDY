import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:study/GoogleAPI/Authentication/Authentication.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:study/GoogleAPI/Calendar/CalendarAPI.dart';

/*
CalendarData
A DAO class to obtain data from the google Calendar API, and manipulate it to
utilize it in ways necessary.
    markedDataMap: the eventlist that can be parsed by the calendar builder
    eventCal: the map of the events
    events: the events gotten from api
    c: the persistencee layer
 */


class CalendarData{
  EventList<Event> markedDateMap = new EventList<Event>();
  Map<DateTime, List> eventCal;
  calendar.CalendarApi events;
  CalendarBuilder c = CalendarBuilder();

  Future<calendar.CalendarApi>gettingCalendar(){
    return c.gettingCalendar();
  }

  // returning and parsing events in a map, so that each day has the events associated with it
  Future<Map<DateTime, List>> getEventMap(calendar.CalendarApi events) async {
    // creating a map
    Map<DateTime, List> eventCal = {};
    //getting events
    var _events = await c.getEvents(events);
    // for each event, if the day is already in the map, add it to the list, otherwise create a new entry
    _events.items.forEach((_event) {
      print(_event.start.dateTime);
      if(_event.start.dateTime!=null) {
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
            eventCal[eventTime] = DayEvents;
          }
        } else {
          List<String> DayEvents = [summary];
          eventCal[(eventTime)] = DayEvents;
        }
      }
    });
    return eventCal;
  }
  Future<bool> loadEvents() async {

    events = await gettingCalendar();
    eventCal = await getEventMap(events);
    print("in load events");
    var dates = eventCal.keys;
    var date;
    for (int i = 0; i < dates.length; i++) {
      date = dates.elementAt(i);
      for (var i = 0; i < eventCal[date].length; i++) {
        Event x = new Event(
          date: date,
          title: eventCal[date][i],
          icon: null,
        );
        if (!contains(x)) {
          markedDateMap.add(
              date,
              new Event(
                date: date,
                title: eventCal[date][i],
                icon: null,
              ));
        }
      }
    }

    return (true);
  }

  bool contains(Event i) {
    List events = markedDateMap.getEvents(i.date);
    for (Event e in events) {
      if (e == i) {
        return true;
      }
    }
    return false;
  }
}