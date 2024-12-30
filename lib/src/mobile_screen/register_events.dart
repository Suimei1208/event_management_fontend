// ignore_for_file: use_build_context_synchronously

import 'package:event_management/src/mobile_screen/detail_event.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventRegisterScreen extends StatefulWidget {
  const EventRegisterScreen({super.key});

  static const routeName = "/register_events";

  @override
  State<EventRegisterScreen> createState() => _EventRegisterScreenState();
}

class _EventRegisterScreenState extends State<EventRegisterScreen> {
  // Use a Future to load events dynamically
  late Future<List<Map<String, dynamic>>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = fetchEventCanRegister(); // Fetch events dynamically
  }

  // Register user for an event
  Future<void> _registerForEvent(String eventId) async {
    try {
      await UserRegisterEvent(eventId);
      LoggerService.logger.i("Successfully registered for event: $eventId");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully registered for the event")),
      );
      setState(() {
        _eventsFuture =
            fetchEventCanRegister(); // Reload events after registration
      });
    } catch (e) {
      LoggerService.logger.e("Error registering for event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to register for the event: $e")),
      );
    }
  }

  // Unregister user from an event
  Future<void> _unregisterFromEvent(String eventId) async {
    try {
      await unregisterEvent(eventId);
      LoggerService.logger.i("Successfully unregistered from event: $eventId");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Successfully unregistered from the event")),
      );
      setState(() {
        _eventsFuture =
            fetchEventCanRegister(); // Reload events after unregistration
      });
    } catch (e) {
      LoggerService.logger.e("Error unregistering from event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to unregister from the event: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Events"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("No events available for registration"));
          }

          final events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(event);
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final user = event["user"];
    final String? isRegistered = event["isRegistered"];
    final eventObj = Event.fromJson(event);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event["name"],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  "${_formatDate(event["startDate"])} - ${_formatDate(event["endDate"])}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user["photoUrl"]),
                  radius: 16.0,
                ),
                const SizedBox(width: 8),
                Text(
                  user["name"],
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsPage(event: eventObj),
                      ),
                    );
                  },
                  child: const Text("View Details"),
                ),
                ElevatedButton(
                  onPressed: isRegistered == "Approved"
                      ? null
                      : () async {
                          if (isRegistered == null) {
                            await _registerForEvent(event["id"].toString());
                          } else if (isRegistered == "Pending") {
                            await _unregisterFromEvent(event["id"].toString());
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegistered == "Approved"
                        ? Colors.grey
                        : (isRegistered == "Pending"
                            ? Colors.red
                            : Colors.blue),
                  ),
                  child: Text(
                    isRegistered == "Approved"
                        ? "Approved"
                        : (isRegistered == "Pending" ? "Cancel" : "Register"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat.yMMMd().format(parsedDate);
    } catch (e) {
      LoggerService.logger.e("Error parsing date: $e");
      return "Invalid Date";
    }
  }
}
