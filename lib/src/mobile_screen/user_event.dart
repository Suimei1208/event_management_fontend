import 'package:event_management/src/mobile_screen/create_event.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserEvents extends StatefulWidget {
  const UserEvents({super.key});

  static const routeName = '/user-events';

  @override
  State<UserEvents> createState() => _UserEventsState();
}

class _UserEventsState extends State<UserEvents> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<Event>> _eventsFuture;
  List<Event> upcomingEvents = [];
  List<Event> pastEvents = [];

  @override
  void initState() {
    super.initState();
    _eventsFuture = fetchEvents();
  }

  void _separateEvents(List<Event> events) {
    final now = DateTime.now();

    upcomingEvents =
        events.where((event) => event.startDate.isAfter(now)).toList();

    pastEvents =
        events.where((event) => event.startDate.isBefore(now)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        title: Text(
          'My Events',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 24,
            ),
            onPressed: () {
              LoggerService.logger.i('IconButton pressed ...');
            },
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FutureBuilder<List<Event>>(
            future: _eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                _separateEvents([]);
              } else {
                _separateEvents(snapshot.data!);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Events',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, CreateEvent.routeName);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Create Event'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Display Upcoming Events
                        ...upcomingEvents
                            .map((event) => EventCard(event: event)),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Past Events',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        // Display Past Events
                        ...pastEvents.map((event) => EventCard(event: event)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  // Method to get status colors based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return const Color(0xFFE8F5E9);
      case 'Canceled':
        return const Color(0xFFFFEBEE);
      case 'Completed':
        return const Color(0xFFE0E0E0);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColorType(String type) {
    switch (type) {
      case 'Seminar':
        return Colors.green.shade600;
      case 'Workshop':
        return Colors.blue.shade600;
      case 'Conference':
        return Colors.red.shade600;
      case 'Competitions':
        return Colors.purple.shade600;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusTextColor(String status, BuildContext context) {
    switch (status) {
      case 'Upcoming':
        return const Color(0xFF2E7D32);
      case 'Canceled':
        return const Color(0xFFC62828);
      case 'Completed':
        return Theme.of(context).textTheme.bodySmall?.color ?? Colors.black;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(event.status);
    final statusTextColor = _getStatusTextColor(event.status, context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Material(
        color: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          DateFormat('MMMM d, yyyy • h:mm a')
                              .format(event.startDate),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            child: Text(
                              event.status,
                              style: TextStyle(
                                color: statusTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFFF6F00),
                            size: 16,
                          ),
                          onPressed: () {
                            LoggerService.logger
                                .i('Delete Event button pressed');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.location,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        child: Text(
                          event.type,
                          style: TextStyle(
                            color: _getStatusColorType(event.type),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
