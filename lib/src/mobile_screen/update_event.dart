// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously
import 'package:event_management/src/mobile_screen/add_guest.dart';
import 'package:event_management/src/mobile_screen/schedules.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/notification_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateEvent extends StatefulWidget {
  final int eventId;

  const UpdateEvent({super.key, required this.eventId});

  static const routeName = '/update_event';

  @override
  State<UpdateEvent> createState() => _UpdateEventState();
}

class _UpdateEventState extends State<UpdateEvent> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> guest = [];
  List<Map<String, dynamic>> speaker = [];
  String? choiceChipsValue;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController _textController1 =
      TextEditingController(); // Event Name
  final TextEditingController _textController2 =
      TextEditingController(); // Description
  final TextEditingController _textController3 =
      TextEditingController(); // Target Audience
  final TextEditingController _textController4 =
      TextEditingController(); // Location
  final TextEditingController dateController =
      TextEditingController(); // Start Date
  final TextEditingController timeController =
      TextEditingController(); // Start Time
  final TextEditingController endDateController =
      TextEditingController(); // End Date
  final TextEditingController endTimeController =
      TextEditingController(); // End Time

  Widget _buildParticipantsList(List<Map<String, dynamic>> participants,
      String title, BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      onPressed: () async {
                        final selectedUsers = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddMembersPage(name: title),
                          ),
                        );
                        if (selectedUsers != null) {
                          setState(() {
                            participants.addAll(selectedUsers);
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (participants.isEmpty)
                  const Center(
                    child: Text('No participants added yet.'),
                  )
                else
                  ...participants.map((participant) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: participant['photoUrl'] !=
                                            null &&
                                        participant['photoUrl'].isNotEmpty
                                    ? NetworkImage(participant['photoUrl'])
                                    : const NetworkImage(
                                        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      participant['name']!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontFamily: 'Inter',
                                          ),
                                    ),
                                    Text(
                                      participant['role']!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontFamily: 'Inter',
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 20,
                                ),
                                onPressed: () {
                                  LoggerService.logger
                                      .e('Remove member button pressed');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  @override
  void dispose() {
    _textController1.dispose();
    _textController2.dispose();
    _textController3.dispose();
    _textController4.dispose();
    dateController.dispose();
    timeController.dispose();
    endDateController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadEventData() async {
    try {
      EventWithParticipants event =
          await fetchEventWithParticipantsById(widget.eventId);
      List<Map<String, dynamic>> guestList = [];
      List<Map<String, dynamic>> speakerList = [];

      for (var participant in event.participants) {
        final userData = await getUserData(participant.userId);

        if (participant.role == 'Guest') {
          guestList.add({
            'userId': participant.userId,
            'role': userData['role'],
            'id': participant.id,
            'name': userData['name'],
            'photoUrl': userData['photoUrl'],
          });
        } else if (participant.role == 'Speaker') {
          speakerList.add({
            'userId': participant.userId,
            'role': userData['role'],
            'name': userData['name'],
            'photoUrl': userData['photoUrl'],
          });
        }
      }

      setState(() {
        _textController1.text = event.name;
        _textController2.text = event.description;
        _textController3.text = event.targetAudience;
        _textController4.text = event.location;
        choiceChipsValue = event.type;
        dateController.text = DateFormat('yyyy-MM-dd').format(event.startDate);
        timeController.text = DateFormat('HH:mm').format(event.startDate);
        endDateController.text = DateFormat('yyyy-MM-dd').format(event.endDate);
        endTimeController.text = DateFormat('HH:mm').format(event.endDate);
        guest = guestList;
        speaker = speakerList;
      });
    } catch (error) {
      LoggerService.logger.e('Failed to load event data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load event data. Please try again.')),
      );
    }
  }

  Future<void> _updateEvent() async {
    try {
      if (speaker.isNotEmpty) {
        await addParticipant(speaker, widget.eventId, "Speaker");
      }
      if (guest.isNotEmpty) {
        await addParticipant(guest, widget.eventId, "Guest");
      }

      String name = _textController1.text;
      String description = _textController2.text;
      String targetAudience = _textController3.text;
      String location = _textController4.text;
      String startDateTime =
          _combineDateTime(dateController.text, timeController.text);
      String endDateTime =
          _combineDateTime(endDateController.text, endTimeController.text);

      final updatedEvent = Event(
        id: widget.eventId,
        name: name,
        description: description,
        targetAudience: targetAudience,
        location: location,
        type: choiceChipsValue!,
        startDate: DateTime.parse(startDateTime),
        endDate: DateTime.parse(endDateTime),
        banner: '123456789',
        status: 'Upcoming',
        idCreate: '',
      );

      await updateEvent(updatedEvent, context);
      await subscribeToTopic('event-${widget.eventId}');
      await sendNotification('Event updated',
          'Please check the updated event details', 'event-${widget.eventId}');

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully!')),
      );
    } catch (error) {
      LoggerService.logger.e('Failed to update event: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to update event. Please try again.')),
      );
    }
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

      return dateTime.toString();
    } else {
      throw Exception('Invalid date or time');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        timeController.text =
            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00";
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        endDateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        endTimeController.text =
            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00";
      });
    }
  }

  String? textController1Validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter event name';
    }
    return null;
  }

  String? textController2Validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }
    return null;
  }

  String? textController3Validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter event objectives';
    }
    return null;
  }

  String? textController4Validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter event location';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Update Event',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Inter Tight',
                  letterSpacing: 0.0,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: const [],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit the details below to update your event.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'Inter', letterSpacing: 0.0, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Column(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _textController1,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Event Name',
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                              hintText: 'Enter event name...',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              contentPadding:
                                  const EdgeInsetsDirectional.fromSTEB(
                                      24, 24, 20, 24),
                            ),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                            validator: textController1Validator,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 16, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Event Type',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 30),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    'Seminar',
                                    'Workshop',
                                    'Conference',
                                    'Competition'
                                  ]
                                      .map((type) => ChoiceChip(
                                            label: Text(type),
                                            selected: choiceChipsValue == type,
                                            onSelected: (selected) {
                                              setState(() {
                                                choiceChipsValue =
                                                    selected ? type : null;
                                              });
                                            },
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                              controller: _textController2,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                                hintText: 'Describe your event...',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                contentPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        24, 24, 20, 24),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                              maxLines: 5,
                              minLines: 3,
                              validator: textController2Validator),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 16, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Event Objectives',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 30),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                      controller: _textController3,
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        hintText: 'Enter event objectives...',
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontFamily: 'Inter',
                                              letterSpacing: 0.0,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).dividerColor,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        contentPadding:
                                            const EdgeInsetsDirectional
                                                .fromSTEB(24, 24, 20, 24),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                      minLines: 2,
                                      maxLines: 4,
                                      validator: textController3Validator),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 16, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Date & Time',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _selectDate(context),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .dividerColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(12, 12, 12, 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: TextField(
                                                    controller: dateController,
                                                    readOnly: true,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'Select Date',
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _selectTime(context),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .dividerColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(12, 12, 12, 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: TextField(
                                                    controller: timeController,
                                                    readOnly: true,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'Select Time',
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const SizedBox(height: 20),
                                Text(
                                  'End Date & Time',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _selectEndDate(context),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .dividerColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(12, 12, 12, 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        endDateController,
                                                    readOnly: true,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          'Select End Date',
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _selectEndTime(context),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .dividerColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(12, 12, 12, 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        endTimeController,
                                                    readOnly: true,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          'Select End Time',
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 16, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Location',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 30),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                      controller: _textController4,
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        hintText: 'Enter event location...',
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontFamily: 'Inter',
                                              letterSpacing: 0.0,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).dividerColor,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        contentPadding:
                                            const EdgeInsetsDirectional
                                                .fromSTEB(24, 24, 20, 24),
                                        suffixIcon: const Icon(
                                          Icons.place,
                                        ),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                      validator: textController4Validator),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                        _buildParticipantsList(speaker, 'Speaker', context),
                        _buildParticipantsList(guest, 'Guest', context),
                      ],
                    ),
                  ]),
                  Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Event Objectives',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 30,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _textController3,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Enter event objectives...',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                contentPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        24, 24, 20, 24),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                              minLines: 2,
                              maxLines: 4,
                              validator: (value) {
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SchedulesWidget(
                                          eventId: widget.eventId,
                                          userRole: 'Organizer',
                                        )),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Setting Schedules',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateEvent,
                      child: const Text('Update Event'),
                    ),
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
