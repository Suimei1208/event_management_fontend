// ignore_for_file: library_private_types_in_public_api

import 'package:event_management/src/mobile_screen/event/create_event.dart';
import 'package:event_management/src/mobile_screen/event/detail_event.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/widget/dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:event_management/generated/l10n.dart';

class UserEvents extends StatefulWidget {
  static const routeName = '/user-events';
  const UserEvents({super.key});

  @override
  _UserEventsState createState() => _UserEventsState();
}

class _UserEventsState extends State<UserEvents> {
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

  Future<void> _navigateToCreateEvent(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEvent()),
    );
    _loadEvents();
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
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        title: Text(
          S.of(context).manage_event,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 24,
            ),
            onPressed: _toggleView,
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 24,
            ),
            onPressed: () => _navigateToCreateEvent(context),
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
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
                          'Không tìm thấy sự kiện nào.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : (_isGridView
                        ? GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
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
                          )),
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
        return const Color.fromARGB(255, 154, 187, 177);
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
    // final brightness = Theme.of(context).brightness;
    final statusColor = _getStatusColor(event.status);
    final statusTextColor = _getStatusTextColor(event.status, context);

    if (isGridView) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsPage(event: event),
            ),
          );
        },
        child: Center(
          child: Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Card(
                // color: brightness == Brightness.dark ? Colors.grey[600] : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(event.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.date_range_outlined),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              child: Text(DateFormat('d/MM/yyyy')
                                  .format(event.startDate))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timelapse),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              child: Text(DateFormat('h:mm a')
                                  .format(event.startDate))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(event.location,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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
                                      'Không thể xóa sự kiện sắp diễn ra hoặc đang diễn ra!',
                                  title: 'Notification',
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsPage(event: event),
              ),
            );
          },
          child: Card(
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                border: Border.all(width: 0.3),
                // color: brightness == Brightness.dark ? Colors.grey[600] : null,
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
                          Text(
                            event.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                            // style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            DateFormat('MMMM d, yyyy • h:mm a')
                                .format(event.startDate),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  softWrap: true,
                                ),
                              ),
                              const SizedBox(width: 10),
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
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                                fontSize: 15,
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
                            LoggerService.logger.i(event.status);
                            if (event.status.trim() == 'Cancelled') {
                              deleteEvent(event.id, context)
                                  .then((_) => loadEvents());
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const DialogWidget(
                                    message:
                                        'Không thể xóa sự kiện sắp diễn ra hoặc đang diễn ra!',
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
}
