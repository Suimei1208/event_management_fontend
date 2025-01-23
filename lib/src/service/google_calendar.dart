// ignore: file_names
import 'dart:convert';

import 'package:event_management/src/service/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';

Future<void> addGoogleCalendarEvent(String name,
    String? description,
    DateTime startDate,
    DateTime endDate, BuildContext context) async {
  final credentialsJson = await rootBundle.loadString('assets/client_secret.json');
  final credentials = ServiceAccountCredentials.fromJson(json.decode(credentialsJson));

  // ignore: no_leading_underscores_for_local_identifiers
  const _scopes = [CalendarApi.calendarScope];

  final client = await clientViaServiceAccount(credentials, _scopes);

  try {
    final calendarApi = CalendarApi(client);

    final event = Event()
      ..summary = name
      ..description = description
      ..start = EventDateTime(dateTime: startDate, timeZone: "GMT+07:00")
      ..end = EventDateTime(dateTime: endDate, timeZone: "GMT+07:00");

    await calendarApi.events.insert(event, "primary");

    LoggerService.logger.i("Sự kiện đã được thêm thành công vào Google Calendar!");
     // ignore: use_build_context_synchronously
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sự kiện đã được thêm thành công vào Google Calendar!")),
    );
  } catch (e) {
    LoggerService.logger.i("Lỗi khi thêm sự kiện: $e");
  } finally {
    client.close();
  }
}