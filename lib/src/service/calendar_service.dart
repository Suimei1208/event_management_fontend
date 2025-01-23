// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:event_management/src/service/logger_service.dart';

final DeviceCalendarPlugin _calendarPlugin = DeviceCalendarPlugin();

Future<bool> requestPermissionsCalendar() async {
  final permissions = await _calendarPlugin.requestPermissions();
  return permissions.data ?? false;
}

Future<List<Calendar>> getCalendars() async {
  final result = await _calendarPlugin.retrieveCalendars();
  if (result.isSuccess && result.data != null) {
    return result.data!;
  }
  return [];
}

Future<List<Event>> getEvents(
    String calendarId, DateTime startDate, DateTime endDate) async {
  final result = await _calendarPlugin.retrieveEvents(
    calendarId,
    RetrieveEventsParams(startDate: startDate, endDate: endDate),
  );
  if (result.isSuccess && result.data != null) {
    return result.data!;
  }
  return [];
}

Future<void> addEventWithCheck(
    BuildContext context,
    String calendarId,
    String name,
    String? description,
    DateTime startDate,
    DateTime endDate) async {
  if (!context.mounted) return;

  final existingEvents = await getEvents(calendarId, startDate, endDate);

  final isDuplicate = existingEvents.any((event) =>
      event.title == name &&
      event.description == description &&
      event.start!.isAtSameMomentAs(startDate) &&
      event.end!.isAtSameMomentAs(endDate));

  if (isDuplicate) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sự kiện đã được thêm trước đó!")),
      );
    }
    LoggerService.logger.i("Sự kiện đã tồn tại, không thêm.");
  } else {
    final event = Event(calendarId,
        title: name,
        description: description!.isNotEmpty ? description : null,
        start: TZDateTime.from(startDate, local),
        end: TZDateTime.from(endDate, local));

    final result = await _calendarPlugin.createOrUpdateEvent(event);
    if (result!.isSuccess) {
      LoggerService.logger.i("Thêm sự kiện thành công.");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm sự kiện thành công!")),
        );
      }
    } else {
      LoggerService.logger.i("Không thể thêm sự kiện.");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm sự kiện thất bại!")),
        );
      }
    }
  }
}
