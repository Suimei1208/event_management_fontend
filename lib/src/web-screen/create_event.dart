// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WebCreateEvent extends StatefulWidget {
  const WebCreateEvent({super.key});
  static const routeName = '/home/create-event';
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<WebCreateEvent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _objectivesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  String? _eventType;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _objectivesController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    super.dispose();
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
        _startDateController.text =
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
        _startTimeController.text =
            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00";
      });
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

      LoggerService.logger.i(dateTime.toString());
      return dateTime.toString();
    } else {
      throw Exception('Invalid date or time');
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
        _endDateController.text =
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
        _endTimeController.text =
            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00";
      });
    }
  }

  void _createEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Combine start and end date and time
        String startDateTime = _combineDateTime(
          _startDateController.text,
          _startTimeController.text,
        );
        String endDateTime = _combineDateTime(
          _endDateController.text,
          _endTimeController.text,
        );

        // Create an Event object
        Event event = Event(
          id: 0,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          targetAudience: _objectivesController.text.trim(),
          location: _locationController.text.trim(),
          type: _eventType!,
          startDate: DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(startDateTime),
          endDate: DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(endDateTime),
          banner:
              "https://ik.imagekit.io/9nhhlzjgp/placeholder-1920x1080.png?updatedAt=1737867365664",
          status: "Upcoming",
          idCreate: "",
          access: false,
          allowSelectSchedule: false,
        );

        // Log the event object
        LoggerService.logger.w(event.toJson());

        // Call the createEvent function
        int eventId = await createEvent(event, context);

        // Handle the result
        if (eventId != 0) {
          await UserRegisterEvent(eventId, "Approved", "Host-$eventId");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully!')),
          );
        } else {
          throw Exception('Event creation failed, invalid event ID.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e')),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.deepPurple,
            ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        onTap: onTap,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Event Details'),
              _buildTextField(label: 'Event Name', controller: _nameController),
              _buildTextField(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 4,
              ),
              _buildTextField(
                label: 'Location',
                controller: _locationController,
                maxLines: 4,
              ),
              _buildTextField(
                label: 'Objective',
                controller: _objectivesController,
                maxLines: 4,
              ),
              DropdownButtonFormField<String>(
                value: _eventType,
                items: ['Seminar', 'Workshop', 'Conference', 'Competition']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _eventType = value;
                }),
                decoration: InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an event type';
                  }
                  return null;
                },
              ),
              _buildSectionTitle('Event Date'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Start Date',
                      controller: _startDateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      suffixIcon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Start Time',
                      controller: _startTimeController,
                      readOnly: true,
                      onTap: () => _selectTime(context),
                      suffixIcon: Icons.access_time,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'End Date',
                      controller: _endDateController,
                      readOnly: true,
                      onTap: () => _selectEndDate(context),
                      suffixIcon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'End Time',
                      controller: _endTimeController,
                      readOnly: true,
                      onTap: () => _selectEndTime(context),
                      suffixIcon: Icons.access_time,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _createEvent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
