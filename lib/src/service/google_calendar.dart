// ignore: file_names
// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'package:event_management/src/service/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart' as google_cal;
import 'package:event_management/src/models/events.dart' as local_event;

import 'package:googleapis/calendar/v3.dart';

Future<void> addGoogleCalendarEvent({
  required String? email,
  required String name,
  String? description,
  required DateTime startDate,
  required DateTime endDate,
  required BuildContext context,
}) async {
  try {
    final credentialsJson =
        await rootBundle.loadString('assets/json/client_secret.json');
    final credentials =
        ServiceAccountCredentials.fromJson(json.decode(credentialsJson));

    const scopes = [CalendarApi.calendarScope];

    final client = await clientViaServiceAccount(credentials, scopes);

    final calendarApi = CalendarApi(client);

    LoggerService.logger.i("Attempting to add event to Google Calendar: $name");

    // Fetch events in the time range
    final events = await calendarApi.events.list(
      email!,
      timeMin: startDate.subtract(const Duration(seconds: 1)),
      timeMax: endDate.add(const Duration(seconds: 1)),
      singleEvents: true,
      orderBy: "startTime",
    );

    // Improved duplicate detection logic
    final duplicateEvent = events.items?.any((event) {
      final existingStart = event.start?.dateTime?.toIso8601String();
      final existingEnd = event.end?.dateTime?.toIso8601String();

      final newStart = startDate.toUtc().toIso8601String();
      final newEnd = endDate.toUtc().toIso8601String();

      return event.summary == name &&
          existingStart == newStart &&
          existingEnd == newEnd;
    });

    if (duplicateEvent == true) {
      LoggerService.logger.w("Duplicate event detected: $name");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event already exists in the calendar.")),
      );
      return;
    }

    // Create the new event
    final event = Event()
      ..summary = name
      ..description = description
      ..start = EventDateTime(dateTime: startDate, timeZone: "Asia/Ho_Chi_Minh")
      ..end = EventDateTime(dateTime: endDate, timeZone: "Asia/Ho_Chi_Minh");

    LoggerService.logger.i("Event created: $event");

    // Insert the event into the calendar
    await calendarApi.events.insert(event, email);
    LoggerService.logger.i("Event added to calendar successfully.");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Event successfully added to Google Calendar!")),
    );
  } catch (e) {
    LoggerService.logger.e("Failed to add event: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to add event: $e")),
    );
  }
}

local_event.Event convertToLocalEvent(google_cal.Event googleEvent) {
  return local_event.Event(
    id: 0,
    name: googleEvent.summary ?? '',
    idCreate: '',
    description: googleEvent.description ?? '',
    startDate: googleEvent.start?.dateTime ?? DateTime.now(),
    endDate: googleEvent.end?.dateTime ?? DateTime.now(),
    location: googleEvent.location ?? '',
    targetAudience: '',
    banner: '',
    status: '',
    type: '',
    access: false,
    allowSelectSchedule: false,
  );
}

Future<List<local_event.Event>> fetchGoogleCalendarEvents(
    BuildContext context, String? email) async {
  final credentialsJson =
      await rootBundle.loadString('assets/json/client_secret.json');
  final credentials =
      ServiceAccountCredentials.fromJson(json.decode(credentialsJson));

  const scopes = [CalendarApi.calendarScope];

  try {
    final client = await clientViaServiceAccount(credentials, scopes);
    final calendarApi = CalendarApi(client);

    final now = DateTime.now();
    final timeMin = DateTime(now.year, now.month, now.day);
    final timeMax = DateTime(now.year + 1, now.month, now.day);

    final events = await calendarApi.events.list(
      email!,
      timeMin: timeMin,
      timeMax: timeMax,
      singleEvents: true,
      orderBy: 'startTime',
    );

    client.close();

    LoggerService.logger.i("Fetched events from Google Calendar!");

    return events.items
            ?.map((googleEvent) => convertToLocalEvent(googleEvent))
            .toList() ??
        [];
  } catch (e) {
    LoggerService.logger.e("Error fetching events from Google Calendar: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch events: $e')),
    );
    return [];
  }
}
