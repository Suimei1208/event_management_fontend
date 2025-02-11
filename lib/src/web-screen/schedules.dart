// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WebSchedulesWidget extends StatefulWidget {
  final int eventId;
  const WebSchedulesWidget({
    super.key,
    required this.eventId,
  });
  static const routeName = "/home/detail-event/schedules";
  @override
  State<WebSchedulesWidget> createState() => _SchedulesWidgetState();
}

class _SchedulesWidgetState extends State<WebSchedulesWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  User? user = FirebaseAuth.instance.currentUser;
  String eventName = '';
  String eventLocation = '';
  String eventDate = '';
  String eventStartDate = "";
  String eventEndDate = "";
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  List<DateTime> eventDays = [];
  List<Map<String, dynamic>> schedules = [];
  String userRole = "";
  bool allowSelectSchedule = false;

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _loadSchedules();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      Participant? participant =
          await fetchParticipantRoleByUserIdAndEventId(widget.eventId);

      if (participant != null) {
        setState(() {
          userRole = participant.role;
        });
      } else {
        setState(() {
          userRole = "";
        });
      }
    } catch (e) {
      setState(() {
        userRole = "";
      });
      LoggerService.logger.e("Error fetching user role: $e");
    }
  }

  Future<void> _loadEventData() async {
    final eventData = await getEventData(widget.eventId);
    LoggerService.logger.i(eventData);
    setState(() {
      allowSelectSchedule = eventData['data']['allowSelectSchedule'];
      eventName = eventData['data']['name'];
      eventLocation = eventData['data']['location'];
      eventStartDate = eventData['data']['startDate'];
      eventEndDate = eventData['data']['endDate'];
      eventDate =
          "${DateFormat.jm().format(DateTime.parse(eventStartDate))} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(eventStartDate))}";

      startDate = DateTime.parse(eventStartDate);
      endDate = DateTime.parse(eventEndDate);
      eventDays = List.generate(
        endDate.difference(startDate).inDays + 1,
        (index) => startDate.add(Duration(days: index)),
      );
    });
    LoggerService.logger.i(eventDate);
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

    LoggerService.logger.e("startDate: $startDate");
    LoggerService.logger.e("endDate: $endDate");

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
                          initialDate: chosenDate ?? startDate,
                          firstDate: startDate,
                          lastDate: endDate,
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

      try {
        DateTime parsedTime;
        if (time.contains('AM') || time.contains('PM')) {
          parsedTime = DateFormat.jm().parse(time);
        } else {
          final timeParts = time.split(':');
          parsedTime = DateTime(
            0,
            1,
            1,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
        DateTime dateTime = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          parsedTime.hour,
          parsedTime.minute,
        );

        return dateTime.toIso8601String();
      } catch (e) {
        throw Exception('Invalid date or time format: $e');
      }
    } else {
      throw Exception('Invalid date or time');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey, Colors.red],
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
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eventLocation,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      eventDate,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: Colors.white),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
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
                          if (userRole == "Host-${widget.eventId}" ||
                              userRole == "Staff-${widget.eventId}")
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  _editEvent(schedule);
                                } else if (value == 'delete') {
                                  await deleteSchedule(schedule['id']);
                                  _loadSchedules();
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          TextButton(
                            onPressed: allowSelectSchedule
                                ? () async {
                                    await addParticipantToSchedule(
                                        widget.eventId, user!.uid);
                                  }
                                : null,
                            child: const Text('Join'),
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
      floatingActionButton: (userRole == "Host-${widget.eventId}" ||
              userRole == "Staff-${widget.eventId}")
          ? FloatingActionButton(
              onPressed: _addNewEvent,
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add),
            )
          : null,
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

  void _editEvent(Map<String, dynamic> schedule) {
    final TextEditingController timeController = TextEditingController(
        text: DateFormat('h:mm a').format(DateTime.parse(schedule['time'])));
    final TextEditingController titleController =
        TextEditingController(text: schedule['title']);
    final TextEditingController locationController =
        TextEditingController(text: schedule['location']);
    DateTime? chosenDate = DateTime.parse(schedule['time']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Schedule'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: chosenDate!,
                        firstDate: startDate,
                        lastDate: endDate,
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
                        DateFormat('dd/MM/yyyy').format(chosenDate!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(chosenDate!),
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
                        timeController.text,
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
                    locationController.text.isNotEmpty) {
                  try {
                    final date = DateFormat('yyyy-MM-dd').format(chosenDate!);
                    final combinedDateTime =
                        _combineDateTime(date, timeController.text);

                    final updatedEvent = {
                      'time': combinedDateTime,
                      'title': titleController.text.trim(),
                      'location': locationController.text.trim(),
                    };

                    await updateEventInSchedule(schedule['id'], updatedEvent);
                    await _loadSchedules(); // Refresh schedules
                    Navigator.pop(context);
                  } catch (e) {
                    LoggerService.logger.e('Error updating event: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update event')),
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
}
