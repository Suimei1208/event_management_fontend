// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:event_management/config.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/widget/dialog_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> createEvent(Event event, BuildContext context) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    String? idToken = await user.getIdToken();
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/event-service/create-event'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(event.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Success to create event.'),
        ),
      );
      if (responseData['success'] == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Tạo sự kiện thành công'),
              content: const Text('Sự kiện đã được tạo thành công.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create event. Please try again.'),
          ),
        );
      }
    } else {
      LoggerService.logger.w('Failed to create event: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create event 2. Please try again.'),
        ),
      );
    }
  } catch (e) {
    LoggerService.logger.w('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('An error occurred. Please try again.'),
      ),
    );
  }
}

Future<List<Event>> fetchEvents() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    String? idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/event-service/get-event'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> eventsData = responseData['data'] ?? [];
      // LoggerService.logger.e(eventsData);
      final List<Event> events = eventsData
          .map((event) => Event.fromJson(event as Map<String, dynamic>))
          .toList();
      return events;
    } else {
      LoggerService.logger.w('Failed to fetch events: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    LoggerService.logger.w('Error: $e');
    return [];
  }
}

// ignore: non_constant_identifier_names
Future<void> DeleteEvent(int idEvent, BuildContext context) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();

    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/event-service/delete/$idEvent'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Show success dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const DialogWidget(
                message: 'Delete event successfully!',
                title: 'Notification',
              );
            },
          );
        } else {
          // Show failure dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const DialogWidget(
                message: 'Failed to delete event!',
                title: 'Notification',
              );
            },
          );
          throw Exception('Failed to delete event');
        }
      } else {
        // Show failure dialog for HTTP errors
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const DialogWidget(
              message: 'Failed to delete event!',
              title: 'Notification',
            );
          },
        );
        throw Exception('Failed to delete event');
      }
    }
  } catch (e) {
    LoggerService.logger.w('Error: $e');
    throw Exception('Failed to delete event');
  }
}

Future<String> getIdEvent(String name) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    String? idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/event-service/getid?idCreate=${user.uid}&name=$name'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'];
    } else {
      throw Exception('Failed to get event id');
    }
  } catch (e) {
    LoggerService.logger.w('Error: $e');
    throw Exception('Failed to get event id');
  }
}
