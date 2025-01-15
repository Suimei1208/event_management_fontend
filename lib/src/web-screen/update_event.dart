// ignore_for_file: avoid_web_libraries_in_flutter, use_build_context_synchronously

import 'dart:html' as html;
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/user_service_web.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateEventWeb extends StatefulWidget {
  final int eventId;

  const UpdateEventWeb({super.key, required this.eventId});

  @override
  State<UpdateEventWeb> createState() => _UpdateEventWebState();
}

class _UpdateEventWebState extends State<UpdateEventWeb> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _audienceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  String _uploadedBase64Data = "";
  String? selectedEventType;
  html.File? uploadedImage;
  String? uploadedImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    try {
      final event = await fetchEventByEventId(widget.eventId);
      setState(() {
        _nameController.text = event.name;
        _descriptionController.text = event.description;
        _audienceController.text = event.targetAudience;
        _locationController.text = event.location;
        _startDateController.text =
            DateFormat('yyyy-MM-dd').format(event.startDate);
        _startTimeController.text = DateFormat('HH:mm').format(event.startDate);
        _endDateController.text =
            DateFormat('yyyy-MM-dd').format(event.endDate);
        _endTimeController.text = DateFormat('HH:mm').format(event.endDate);
        selectedEventType = event.type;
        uploadedImageUrl = event.banner;
      });
    } catch (error) {
      LoggerService.logger.e('Error loading event data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load event data.')),
      );
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      isLoading = true;
    });

    html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files?.isEmpty ?? true) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final reader = html.FileReader();
      reader.readAsDataUrl(files![0]);

      reader.onLoadEnd.listen((e) {
        setState(() {
          _uploadedBase64Data = reader.result as String;
          uploadedImageUrl = _uploadedBase64Data;
          isLoading = false;
        });
      });
    });
  }

  Future<void> _uploadImage(uploadedBase64Data) async {
    try {
      setState(() {
        isLoading = true;
      });

      String imageUrl = await uploadImageToImageKitWebVersion(
          _uploadedBase64Data, "${widget.eventId}");
      final updatedImageUrl = _appendUpdatedAtQuery(imageUrl);

      setState(() {
        uploadedImageUrl = updatedImageUrl;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  String _appendUpdatedAtQuery(String url) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$url?updatedAt=$timestamp';
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

  Future<void> _updateEvent() async {
    try {
      String name = _nameController.text;
      String description = _descriptionController.text;
      String targetAudience = _audienceController.text;
      String location = _locationController.text;
      String startDateTime = _combineDateTime(
          _startDateController.text, _startTimeController.text);
      String endDateTime =
          _combineDateTime(_endDateController.text, _endTimeController.text);
      if (_uploadedBase64Data != "") {
        await _uploadImage(_uploadedBase64Data);
      }

      final updatedEvent = Event(
          id: widget.eventId,
          name: name,
          description: description,
          targetAudience: targetAudience,
          location: location,
          type: selectedEventType!,
          startDate: DateTime.parse(startDateTime),
          endDate: DateTime.parse(endDateTime),
          banner: uploadedImageUrl!,
          status: 'Upcoming',
          idCreate: '',
          access: false,
          allowSelectSchedule: false);

      await updateEvent(updatedEvent, context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Event Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedEventType,
                      decoration:
                          const InputDecoration(labelText: 'Event Type'),
                      items: [
                        'Seminar',
                        'Workshop',
                        'Conference',
                        'Competition'
                      ]
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEventType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _audienceController,
                      decoration:
                          const InputDecoration(labelText: 'Target Audience'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 12, 12, 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _startDateController,
                                        readOnly: true,
                                        decoration: const InputDecoration(
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
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 12, 12, 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _startTimeController,
                                        readOnly: true,
                                        decoration: const InputDecoration(
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
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectEndDate(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 12, 12, 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _endDateController,
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          hintText: 'Select End Date',
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
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12, 12, 12, 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _endTimeController,
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          hintText: 'Select End Time',
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Select Image'),
                    ),
                    const SizedBox(height: 10),
                    if (uploadedImageUrl != null)
                      Image.network(uploadedImageUrl!,
                          height: 250, width: double.infinity),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateEvent,
                      child: const Text('Update Event'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
