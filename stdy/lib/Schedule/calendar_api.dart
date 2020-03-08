import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:study/Settings/Authentication.dart';

//class CalendarApi

Future<calendar.CalendarApi> gettingCalendar() async {
  calendar.CalendarApi calendarApi;
  Authentication auth = new Authentication();
  calendarApi = new calendar.CalendarApi(auth.authClient);
  return calendarApi;
}