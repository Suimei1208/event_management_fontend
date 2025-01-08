// ignore_for_file: use_build_context_synchronously

import 'package:event_management/generated/l10n.dart';

import 'package:event_management/src/mobile_screen/event/review_event.dart';

import 'package:event_management/src/service/event_service.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventFinishedScreen extends StatefulWidget {
  const EventFinishedScreen({super.key});

  static const routeName = "/register_events";

  @override
  State<EventFinishedScreen> createState() => _EventFinishedScreenState();
}

class _EventFinishedScreenState extends State<EventFinishedScreen> {
  late Future<List<Map<String, dynamic>>> _eventsFuture;
  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _filteredEvents = [];

  String? _selectedType;
  DateTime? _selectedStartDate;

  final List<String> _eventTypes = [
    "Seminar",
    "Workshop",
    "Conference",
    "Competition"
  ];

  @override
  void initState() {
    super.initState();
    _eventsFuture = fetchEventCompleted();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await fetchEventCompleted();
    // LoggerService.logger.i(events);
    if (mounted) {
      setState(() {
        _allEvents = events;
        _filteredEvents = events;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
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

  void _filterEvents(String query) {
    final filtered = _allEvents.where((event) {
      final eventName = event["name"].toLowerCase();
      final searchQuery = query.toLowerCase();
      final matchesType = _selectedType == null ||
          _selectedType!.isEmpty ||
          event["type"] == _selectedType;
      final matchesStartDate = _selectedStartDate == null ||
          DateTime.parse(event["startDate"]).isAfter(_selectedStartDate!) ||
          DateTime.parse(event["startDate"])
              .isAtSameMomentAs(_selectedStartDate!);

      return eventName.contains(searchQuery) && matchesType && matchesStartDate;
    }).toList();

    setState(() {
      _filteredEvents = filtered;
    });
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
      _filterEvents('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Events"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                onChanged: _filterEvents,
                decoration: InputDecoration(
                  hintText: S.of(context).search_event,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: _selectedType,
                items: [
                  const DropdownMenuItem(value: '', child: Text('All Types')),
                  ..._eventTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                  _filterEvents('');
                },
                decoration: InputDecoration(
                  labelText: S.of(context).event_type,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedStartDate == null
                          ? 'Select Start or After Date'
                          : 'Start or After Date: ${DateFormat.yMMMd().format(_selectedStartDate!)}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectStartDate(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("No events available for review"));
                  }

                  return ListView.builder(
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      return _buildEventCard(event);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final user = event["user"];

    return InkWell(
      onTap: event['isReview'] == false
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventReviewPage(
                      eventId: event["id"], eventName: event["name"]),
                ),
              );
            }
          : null,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event["name"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: _getStatusColorType(event["type"]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        event["type"],
                        style: const TextStyle(
                          // color: statusTextColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "By",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
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
                  event['isReview']
                      ? const Text("Đã đánh giá")
                      : const Text("Chưa đánh giá"),
                ],
              ),
              // const SizedBox(height: 16),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     ElevatedButton(
              //       style: Theme.of(context).brightness == Brightness.dark
              //           ? ElevatedButton.styleFrom(backgroundColor: Colors.purple)
              //           : null,
              //       onPressed: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => EventDetailsPage(event: eventObj),
              //           ),
              //         );
              //       },
              //       child: Text(S.of(context).view_detail),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat.yMMMd().format(parsedDate);
    } catch (e) {
      return "Invalid date";
    }
  }
}
