// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:flutter/material.dart';
import 'package:event_management/generated/l10n.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String? _selectedEventType;
  bool _isLoading = false;

  // Controllers for input fields
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _objectivesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Controllers for date and time
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize date and time fields as empty
    _startDateController.text = "";
    _startTimeController.text = "";
    _endDateController.text = "";
    _endTimeController.text = "";
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _eventNameController.dispose();
    _descriptionController.dispose();
    _objectivesController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  /// Combines date and time strings into a DateTime object
  DateTime _combineDateTime(String date, String time) {
    final dateParts = date.split('-');
    final timeParts = time.split(':');

    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  /// Handles the creation of the event when the user presses the "Create Event" button
  Future<void> _handleCreateEvent() async {
    // First, validate the form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if event type is selected
    if (_selectedEventType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select an event type'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    // Check if all date and time fields are filled
    if (_startDateController.text.isEmpty ||
        _startTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select both start date and time'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    if (_endDateController.text.isEmpty || _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select both end date and time'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    // Combine date and time into DateTime objects
    DateTime startDateTime =
        _combineDateTime(_startDateController.text, _startTimeController.text);
    DateTime endDateTime =
        _combineDateTime(_endDateController.text, _endTimeController.text);

    // Validate that end date is after start date
    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('End date and time must be after start date and time'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    // Create the Event object
    Event event = Event(
      id: 0, // This will be set by the backend or service
      name: _eventNameController.text.trim(),
      description: _descriptionController.text.trim(),
      targetAudience: _objectivesController.text.trim(),
      location: _locationController.text.trim(),
      type: _selectedEventType!,
      startDate: startDateTime,
      endDate: endDateTime,
      banner: "https://placehold.jp/400x200.png", // Placeholder banner URL
      status: "Upcoming",
      idCreate: "", // Set this to the creator's ID if available
      access: false,
      allowSelectSchedule: false,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to create the event
      int eventId = await createEvent(event, context);

      if (eventId != 0) {
        // Register the user as the host of the event
        await UserRegisterEvent(
          eventId,
          "Approved",
          "Host-$eventId",
        );

        // Optionally, navigate to the event details page
        Navigator.of(context).pop(); // Goes back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to create event'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      LoggerService.logger.e('Error creating event: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
        duration: const Duration(seconds: 2),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Opens a date picker and sets the selected date to the provided controller
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  /// Opens a time picker and sets the selected time to the provided controller
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        controller.text =
            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        key: scaffoldKey,
        // backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            S.of(context).create_event,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Inter Tight',
                  letterSpacing: 0.0,
                ),
          ),
          // backgroundColor: Theme.of(context).colorScheme.surface,
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
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey, // Assign the form key
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Guide Text
                    Text(
                      S.of(context).guide_create_event,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'Inter',
                          letterSpacing: 0.0,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    // Event Name Field
                    TextFormField(
                      controller: _eventNameController,
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: S.of(context).event_name,
                        labelStyle:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                        hintText:
                            "${S.of(context).enter} ${S.of(context).event_name}",
                        hintStyle:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 24),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter event name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Event Type Selection
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              S.of(context).event_type,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                            ),
                            const SizedBox(height: 12),
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
                                        selected: _selectedEventType == type,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedEventType =
                                                selected ? type : null;
                                          });
                                        },
                                      ))
                                  .toList(),
                            ),
                            if (_selectedEventType == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Please select an event type',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: S.of(context).desc,
                        labelStyle:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                        hintText:
                            "${S.of(context).describe} ${S.of(context).desc}",
                        hintStyle:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 24),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Objectives Field
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              S.of(context).obj,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _objectivesController,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText:
                                    "${S.of(context).enter} ${S.of(context).obj}",
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
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 24),
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
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter event objectives';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Start Date and Time Selection
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              S.of(context).start_date,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Start Date Picker
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectDate(
                                        context, _startDateController),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                    _startDateController,
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
                                // Start Time Picker
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectTime(
                                        context, _startTimeController),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                    _startTimeController,
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

                            // Optionally, you can add validation messages here
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // End Date and Time Selection
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              S.of(context).end_date,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // End Date Picker
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectDate(
                                        context, _endDateController),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextField(
                                                controller: _endDateController,
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
                                // End Time Picker
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectTime(
                                        context, _endTimeController),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextField(
                                                controller: _endTimeController,
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

                            // Optionally, you can add validation messages here
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Location Field
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              S.of(context).location,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _locationController,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText:
                                    "${S.of(context).enter} ${S.of(context).location}",
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
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 24),
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
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter event location';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Additional Content (Empty Container in Original Code)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      // You can add more widgets here if needed
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCreateEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  // color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                S.of(context).create_event,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
