// import 'package:device_calendar/device_calendar.dart' as device_calendar;
// import 'package:device_calendar/device_calendar.dart';
// import 'package:event_management/src/models/events.dart';

// class CalendarService {
//   final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

//   Future<bool> requestPermissions() async {
//     var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
//     if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
//       permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
//       return permissionsGranted.isSuccess && permissionsGranted.data;
//     }
//     return true;
//   }

//   Future<List<Calendar>> retrieveCalendars() async {
//     var permissionsGranted = await requestPermissions();
//     if (!permissionsGranted) {
//       return [];
//     }
//     final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
//     return calendarsResult?.data ?? [];
//   }

//   Future<void> addEventToCalendar(Event event) async {
//     final calendars = await retrieveCalendars();
//     if (calendars.isNotEmpty) {
//       final calendar = calendars.firstWhere((c) => c.isDefault);
//       final newEvent = device_calendar.Event(
//         calendar.id,
//         title: event.name,
//         description: event.description,
//         start: event.startDate,
//         end: event.endDate,
//         location: event.location,
//       );
//       await _deviceCalendarPlugin.createOrUpdateEvent(newEvent);
//     }
//   }
// }
