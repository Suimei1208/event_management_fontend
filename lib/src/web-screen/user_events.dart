// ignore_for_file: library_private_types_in_public_api

import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/web-screen/create_event.dart';
import 'package:event_management/widget/dialog_widget.dart';

class WebUserEvents extends StatefulWidget {
  static const routeName = '/manage-events';
  const WebUserEvents({super.key});

  @override
  _UserEventsWebState createState() => _UserEventsWebState();
}

class _UserEventsWebState extends State<WebUserEvents> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isGridView = false;
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await fetchEvents();
      setState(() {
        _allEvents = events;
        _filteredEvents = events;
      });
    } catch (error) {
      LoggerService.logger.e('Error loading events: $error');
    }
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _filterEvents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEvents = _allEvents;
      } else {
        _filteredEvents = _allEvents
            .where((event) =>
                event.name.toLowerCase().contains(query.toLowerCase()) ||
                event.location.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _toggleView,
                    icon: const Icon(Icons.tune),
                    label: const Text("Toggle View"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      WebCreateEvent.routeName,
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(S.of(context).create_event),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search bar
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  onChanged: _filterEvents,
                  decoration: InputDecoration(
                    hintText: S.of(context).search_event,
                    prefixIcon: Icon(Icons.search,
                        color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              Expanded(
                child: _filteredEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No events found.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return _isGridView
                              ? GridView.builder(
                                  padding: EdgeInsets.zero,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        constraints.maxWidth > 800 ? 3 : 2,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: 0.555,
                                  ),
                                  itemCount: _filteredEvents.length,
                                  itemBuilder: (context, index) {
                                    return EventCard(
                                      event: _filteredEvents[index],
                                      loadEvents: _loadEvents,
                                      isGridView: _isGridView,
                                    );
                                  },
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: _filteredEvents.length,
                                  itemBuilder: (context, index) {
                                    return EventCard(
                                      event: _filteredEvents[index],
                                      loadEvents: _loadEvents,
                                      isGridView: _isGridView,
                                    );
                                  },
                                );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final bool isGridView;
  final VoidCallback loadEvents;

  const EventCard({
    super.key,
    required this.event,
    required this.loadEvents,
    required this.isGridView,
  });

  Color? _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return const Color(0xFFE8F5E9);
      case 'Cancelled':
        return Colors.red[300];
      case 'Completed':
        return Colors.grey;
      default:
        return const Color.fromARGB(255, 245, 203, 18);
    }
  }

  Color _getStatusTextColor(String status, BuildContext context) {
    switch (status) {
      case 'Upcoming':
        return const Color(0xFF2E7D32);
      case 'Cancelled':
        return Colors.white;
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, "/home/detail-event/${event.id}");
        },
        child: Material(
          color: Colors.transparent,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              border: Border.all(width: 0.3),
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Increased font size for event name
                        Text(
                          event.name,
                          style: const TextStyle(
                            fontSize: 18, // Increased font size
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Increased font size for date and time
                        Text(
                          DateFormat('MMMM d, yyyy • h:mm a')
                              .format(event.startDate),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 16), // Increased font size
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.location,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontSize: 16), // Increased font size
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                              fontSize: 18, // Increased font size
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFFF6F00),
                          size: 30,
                        ),
                        onPressed: () {
                          if (event.status == 'Cancelled') {
                            deleteEvent(event.id, context)
                                .then((_) => loadEvents());
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const DialogWidget(
                                  message:
                                      'Cannot delete events that are upcoming or in progress!',
                                  title: 'Notification',
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
