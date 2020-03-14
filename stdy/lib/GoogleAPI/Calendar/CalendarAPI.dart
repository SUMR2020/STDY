import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:study/GoogleAPI/Authentication/Authentication.dart';
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

}


