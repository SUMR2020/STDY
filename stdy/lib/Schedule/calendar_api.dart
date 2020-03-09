import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:study/Settings/Authentication.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';


class CalendarBuilder {
  EventList<Event> markedDateMap = new EventList<Event>();
  Map<DateTime, List> eventCal;
  calendar.CalendarApi events;

  // function to retrieve a user's primary calendar data, using the authorization from the auth scree
  Future<calendar.CalendarApi> gettingCalendar() async {
  calendar.CalendarApi calendarApi;
  Authentication auth = new Authentication();
  calendarApi = new calendar.CalendarApi(auth.authClient);
  return calendarApi;
  }

  // function to retrieve the last 30, and next 30 days in a user's calendar, using calendar data
  Future<calendar.Events> getEvents(calendar.CalendarApi events) async {
    DateTime start = new DateTime.now().subtract(new Duration(days: 30));
    DateTime end = new DateTime.now().add(new Duration(days: 30));
    var calEvents = events.events.list("primary",
        timeMin: start.toUtc(),
        timeMax: end.toUtc(),
        orderBy: 'startTime',
        singleEvents: true);
    return calEvents;
  }

  // returning and parsing events in a map, so that each day has the events associated with it
  Future<Map<DateTime, List>> getEventMap(calendar.CalendarApi events) async {
    // creating a map
     Map<DateTime, List> eventCal = {};
     //getting events
    var _events = await getEvents(events);
    // for each event, if the day is already in the map, add it to the list, otherwise create a new entry
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
          eventCal[eventTime] = DayEvents;
        }
      } else {
        List<String> DayEvents = [summary];
        eventCal[(eventTime)] = DayEvents;
      }
    });
    return eventCal;
  }

  Future<bool> loadEvents() async {
    events = await gettingCalendar();
    eventCal = await getEventMap(events);
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


