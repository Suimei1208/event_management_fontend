// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulesWidget extends StatefulWidget {
  final int eventId;
  const SchedulesWidget({super.key, required this.eventId});

  @override
  State<SchedulesWidget> createState() => _SchedulesWidgetState();
}

class _SchedulesWidgetState extends State<SchedulesWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String eventName = '';
  String eventLocation = '';
  String eventDate = '';
  DateTime eventStartDate = DateTime.now();
  DateTime eventEndDate = DateTime.now();
  List<DateTime> eventDays = [];
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _loadSchedules();
  }

  Future<void> _loadEventData() async {
    EventWithParticipants event =
        await fetchEventWithParticipantsById(widget.eventId);

    setState(() {
      eventName = event.name;
      eventLocation = event.location;
      eventStartDate = event.startDate;
      eventEndDate = event.endDate;
      eventDate =
          "${DateFormat.jm().format(event.startDate)} - ${event.startDate.day}/${event.startDate.month}/${event.startDate.year}";
      eventDays = List.generate(
        eventEndDate.difference(eventStartDate).inDays + 1,
        (index) => eventStartDate.add(Duration(days: index)),
      );
    });
  }

  Future<void> _loadSchedules() async {
    try {
      List<Map<String, dynamic>> fetchedSchedules =
          await fetchSchedulesForEvent(widget.eventId);
      setState(() {
        schedules = fetchedSchedules;
      });
    } catch (e) {
      LoggerService.logger.e('Failed to load schedules: $e');
    }
  }

  void _addNewEvent({DateTime? selectedDate}) {
    final TextEditingController timeController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    DateTime? chosenDate = selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Schedule'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (eventDays.length > 1)
                    GestureDetector(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: chosenDate ?? eventStartDate,
                          firstDate: eventStartDate,
                          lastDate: eventEndDate,
                        );
                        if (pickedDate != null) {
                          setState(() {
                            chosenDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          chosenDate != null
                              ? DateFormat('dd/MM/yyyy').format(chosenDate!)
                              : 'Select Date',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          timeController.text = pickedTime.format(context);
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        timeController.text.isNotEmpty
                            ? timeController.text
                            : 'Select Time',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (timeController.text.isNotEmpty &&
                    titleController.text.isNotEmpty &&
                    locationController.text.isNotEmpty &&
                    (chosenDate != null || eventDays.length == 1)) {
                  try {
                    final date = DateFormat('yyyy-MM-dd')
                        .format(chosenDate ?? eventDays.first);
                    final combinedDateTime =
                        _combineDateTime(date, timeController.text);

                    final newEvent = {
                      'time': combinedDateTime,
                      'title': titleController.text.trim(),
                      'location': locationController.text.trim(),
                    };

                    LoggerService.logger.i('Payload: ${json.encode(newEvent)}');
                    await addEventToSchedule(widget.eventId, newEvent);
                    await _loadSchedules();
                    Navigator.pop(context);
                  } catch (e) {
                    LoggerService.logger.e('Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add event')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _combineDateTime(String date, String time) {
    if (date.isNotEmpty && time.isNotEmpty) {
      final dateParts = date.split('-');
      final timeParts = time.split(':');

      DateTime dateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      return dateTime.toIso8601String();
    } else {
      throw Exception('Invalid date or time');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text("Event Schedule"),
      ),
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Color(0xFF6A1B9A)],
                  stops: [0, 1],
                  begin: AlignmentDirectional(0, -1),
                  end: AlignmentDirectional(0, 1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eventLocation,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                    Text(
                      eventDate,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  final time = DateFormat('h:mm a')
                      .format(DateTime.parse(schedule['time']));
                  final title = schedule['title'];
                  final location = schedule['location'];

                  return Column(
                    children: [
                      if (index == 0 || index > 0 && _isDifferentDay(index))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            DateFormat('EEEE - MMM d')
                                .format(DateTime.parse(schedule['time'])),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                margin:
                                    const EdgeInsets.only(left: 16, right: 8),
                                decoration: BoxDecoration(
                                  color: _getColorForIndex(index),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 50,
                                color: Colors.grey.shade300,
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    location,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEvent,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _isDifferentDay(int index) {
    final current = DateTime.parse(schedules[index]['time']);
    final previous = DateTime.parse(schedules[index - 1]['time']);
    return current.day != previous.day;
  }

  Color _getColorForIndex(int index) {
    const colors = [
      Colors.purple,
      Colors.blue,
      Colors.orange,
      Colors.green,
    ];
    return colors[index % colors.length];
  }
}
