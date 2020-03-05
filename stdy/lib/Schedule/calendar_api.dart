import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:study/login_page.dart' as login;

//class CalendarApi

Future<calendar.CalendarApi> gettingCalendar() async {
  calendar.CalendarApi calendarApi;
  calendarApi = new calendar.CalendarApi(login.authClient);
  return calendarApi;
}