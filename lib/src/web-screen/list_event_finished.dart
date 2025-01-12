// ignore_for_file: use_build_context_synchronously

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/mobile_screen/event/review_event.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventFinishedScreenWeb extends StatefulWidget {
  const EventFinishedScreenWeb({super.key});
  static const routeName = "/finished-events";

  @override
  State<EventFinishedScreenWeb> createState() => _EventFinishedScreenWebState();
}

class _EventFinishedScreenWebState extends State<EventFinishedScreenWeb> {
  late Future<List<Map<String, dynamic>>> _eventsFuture;
  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _filteredEvents = [];

  String? _selectedType;
  DateTime? _selectedEndDate;

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
    if (mounted) {
      setState(() {
        _allEvents = events;
        _filteredEvents = events;
      });
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

  void _filterEvents(String query) {
    final filtered = _allEvents.where((event) {
      final eventName = event["name"].toLowerCase();
      final searchQuery = query.toLowerCase();
      final matchesType = _selectedType == null ||
          _selectedType!.isEmpty ||
          event["type"] == _selectedType;
      final matchesEndDate = _selectedEndDate == null ||
          DateTime.parse(event["endDate"]).isBefore(_selectedEndDate!) ||
          DateTime.parse(event["endDate"]).isAtSameMomentAs(_selectedEndDate!);

      return eventName.contains(searchQuery) && matchesType && matchesEndDate;
    }).toList();

    setState(() {
      _filteredEvents = filtered;
    });
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
      _filterEvents('');
    }
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat.yMMMd().format(parsedDate);
    } catch (e) {
      return "Invalid date";
    }
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final user = event["user"];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EventReviewPage(
                    eventId: int.parse(event['id'].toString()),
                    eventName: event["name"],
                  )),
        );
      },
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Sidebar for Filters
            Card(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: _filterEvents,
                      decoration: InputDecoration(
                        hintText: S.of(context).search_event,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: [
                        const DropdownMenuItem(
                            value: '', child: Text('All Types')),
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
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedEndDate == null
                                ? 'Select End or Before Date'
                                : 'End or Before Date: ${DateFormat.yMMMd().format(_selectedEndDate!)}',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectEndDate(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Main Content for Events
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text(S.of(context).no_events_available));
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3 / 2,
                    ),
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
}
