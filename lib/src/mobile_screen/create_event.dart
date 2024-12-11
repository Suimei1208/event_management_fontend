// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  static const routeName = '/create_event';

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? choiceChipsValue;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Declare TextEditingControllers
  final TextEditingController _textController1 = TextEditingController();
  final TextEditingController _textController2 = TextEditingController();
  final TextEditingController _textController3 = TextEditingController();
  final TextEditingController _textController4 = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dateController.text = "";
    timeController.text = "";
    endDateController.text = "";
    endTimeController.text = "";
  }

  @override
  void dispose() {
    // Dispose controllers
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        endDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        endTimeController.text = picked.format(context);
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
                    'Create Event',
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
                    'Fill in the details below to create your new event.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'Inter',
                          letterSpacing: 0.0,
                          fontSize: 16
                        ),
                  ),
                  const SizedBox(height: 10,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _textController1, // Updated
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Event Name',
                            labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                            hintText: 'Enter event name...',
                            hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                const EdgeInsetsDirectional.fromSTEB(24, 24, 20, 24),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Event Type',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 30
                                    ),
                              ),
                              Wrap(
                                spacing: 8,
                                children: ['Seminar', 'Workshop', 'Conference', 'Competition']
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
                          controller: _textController2, // Updated
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                            hintText: 'Describe your event...',
                            hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                const EdgeInsetsDirectional.fromSTEB(24, 24, 20, 24),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontFamily: 'Inter',
                                letterSpacing: 0.0,
                              ),
                          maxLines: 5,
                          minLines: 3,
                          validator: textController2Validator
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
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Event Objectives',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 30
                                    ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _textController3, // Updated
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    hintText: 'Enter event objectives...',
                                    hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                                    contentPadding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24, 24, 20, 24),
                                  ),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  minLines: 2,
                                  maxLines: 4,
                                  validator: textController3Validator
                                ),
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
    padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Date & Time',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                onTap: () => _selectDate(context), // Gọi hàm chọn ngày
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
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
                            controller: dateController, // Controller chọn ngày
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
                onTap: () => _selectTime(context), // Gọi hàm chọn giờ
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
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
                            controller: timeController, // Controller chọn giờ
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
        const SizedBox(height: 20),
        Text(
          'End Date & Time',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
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
                            controller: endDateController, // Controller chọn ngày kết thúc
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
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
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
                            controller: endTimeController, // Controller chọn giờ kết thúc
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
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Location',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 30
                                    ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _textController4, // Updated
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    hintText: 'Enter event location...',
                                    hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                                    contentPadding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24, 24, 20, 24),
                                    suffixIcon: const Icon(
                                      Icons.place,
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  validator: textController4Validator
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                      // const SizedBox(height: 20),
                      // Container(
                      //   width: double.infinity,
                      //   decoration: BoxDecoration(
                      //     color: Theme.of(context).cardColor,
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(
                      //       color: Theme.of(context).dividerColor,
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: Padding(
                      //     padding:
                      //         const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                      //     child: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Row(
                      //           mainAxisSize: MainAxisSize.max,
                      //           mainAxisAlignment:
                      //               MainAxisAlignment.spaceBetween,
                      //           children: [
                      //             Text(
                      //               'Speakers',
                      //               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      //                     fontFamily: 'Inter',
                      //                     letterSpacing: 0.0,
                      //                     fontWeight: FontWeight.w600,
                      //                     fontSize: 30
                      //                   ),
                      //             ),
                      //             IconButton(
                      //               icon: Icon(
                      //                 Icons.add,
                      //                 color: Theme.of(context).colorScheme.primary,
                      //                 size: 24,
                      //               ),
                      //               onPressed: () {
                      //                 print('IconButton pressed ...');
                      //               },
                      //             ),
                      //           ],
                      //         ),
                      //         const SizedBox(height: 12),
                      //         Container(
                      //           width: double.infinity,
                      //           decoration: BoxDecoration(
                      //             color: Theme.of(context).scaffoldBackgroundColor,
                      //             borderRadius: BorderRadius.circular(8),
                      //             border: Border.all(
                      //               color: Theme.of(context).dividerColor,
                      //               width: 1,
                      //             ),
                      //           ),
                      //           child: Padding(
                      //             padding: const EdgeInsetsDirectional.fromSTEB(
                      //                 12, 12, 12, 12),
                      //             child: Column(
                      //               mainAxisSize: MainAxisSize.min,
                      //               children: [
                      //                 Row(
                      //                   mainAxisSize: MainAxisSize.max,
                      //                   children: [
                      //                     Container(
                      //                       width: 40,
                      //                       height: 40,
                      //                       decoration: BoxDecoration(
                      //                         color: Theme.of(context).colorScheme.secondary,
                      //                         borderRadius:
                      //                             BorderRadius.circular(20),
                      //                       ),
                      //                       child: Align(
                      //                         alignment:
                      //                             const AlignmentDirectional(0, 0),
                      //                         child: Padding(
                      //                           padding: const EdgeInsets.all(8),
                      //                           child: Text(
                      //                             'JS',
                      //                             textAlign: TextAlign.center,
                      //                             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      //                                   fontFamily: 'Inter',
                      //                                   color: Theme.of(context).primaryColor,
                      //                                   letterSpacing: 0.0,
                      //                                 ),
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                     const SizedBox(width: 12),
                      //                     Expanded(
                      //                       child: Column(
                      //                         mainAxisSize: MainAxisSize.min,
                      //                         crossAxisAlignment:
                      //                             CrossAxisAlignment.start,
                      //                         children: [
                      //                           Text(
                      //                             'John Smith',
                      //                             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      //                                   fontFamily: 'Inter',
                      //                                   letterSpacing: 0.0,
                      //                                 ),
                      //                           ),
                      //                           Text(
                      //                             'AI Research Lead',
                      //                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      //                                   fontFamily: 'Inter',
                      //                                   color: Theme.of(context).textTheme.bodySmall?.color,
                      //                                   letterSpacing: 0.0,
                      //                                 ),
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     ),
                      //                     Icon(
                      //                       Icons.close,
                      //                       color: Theme.of(context).colorScheme.error,
                      //                       size: 20,
                      //                     ),
                      //                   ],
                      //                 ),
                      //                 const SizedBox(height: 12),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         const SizedBox(height: 12),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 20),
                      // Container(
                      //   width: double.infinity,
                      //   decoration: BoxDecoration(
                      //     color: Theme.of(context).cardColor,
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(
                      //       color: Theme.of(context).dividerColor,
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: Padding(
                      //     padding:
                      //         const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                      //     child: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Row(
                      //           mainAxisSize: MainAxisSize.max,
                      //           mainAxisAlignment:
                      //               MainAxisAlignment.spaceBetween,
                      //           children: [
                      //             Text(
                      //               'Special Guests',
                      //               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      //                     fontFamily: 'Inter',
                      //                     letterSpacing: 0.0,
                      //                     fontWeight: FontWeight.w600,
                      //                     fontSize: 30
                      //                   ),

                      //             ),
                      //             IconButton(
                      //               icon: Icon(
                      //                 Icons.add,
                      //                 color: Theme.of(context).colorScheme.primary,
                      //                 size: 24,
                      //               ),
                      //               onPressed: () {
                      //                 print('IconButton pressed ...');
                      //               },
                      //             ),
                      //           ],
                      //         ),
                      //         const SizedBox(height: 12),
                      //         Container(
                      //           width: double.infinity,
                      //           decoration: BoxDecoration(
                      //             color: Theme.of(context).scaffoldBackgroundColor,
                      //             borderRadius: BorderRadius.circular(8),
                      //             border: Border.all(
                      //               color: Theme.of(context).dividerColor,
                      //               width: 1,
                      //             ),
                      //           ),
                      //           child: Padding(
                      //             padding: const EdgeInsetsDirectional.fromSTEB(
                      //                 12, 12, 12, 12),
                      //             child: Column(
                      //               mainAxisSize: MainAxisSize.min,
                      //               children: [
                      //                 Row(
                      //                   mainAxisSize: MainAxisSize.max,
                      //                   children: [
                      //                     Container(
                      //                       width: 40,
                      //                       height: 40,
                      //                       decoration: BoxDecoration(
                      //                         color: Theme.of(context).colorScheme.secondary,
                      //                         borderRadius:
                      //                             BorderRadius.circular(20),
                      //                       ),
                      //                       child: Align(
                      //                         alignment:
                      //                             const AlignmentDirectional(0, 0),
                      //                         child: Padding(
                      //                           padding: const EdgeInsets.all(8),
                      //                           child: Text(
                      //                             'MA',
                      //                             textAlign: TextAlign.center,
                      //                             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      //                                   fontFamily: 'Inter',
                      //                                   color: Theme.of(context).primaryColor,
                      //                                   letterSpacing: 0.0,
                      //                                 ),
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                     const SizedBox(width: 12),
                      //                     Expanded(
                      //                       child: Column(
                      //                         mainAxisSize: MainAxisSize.min,
                      //                         crossAxisAlignment:
                      //                             CrossAxisAlignment.start,
                      //                         children: [
                      //                           Text(
                      //                             'Mary Adams',
                      //                             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      //                                   fontFamily: 'Inter',
                      //                                   letterSpacing: 0.0,
                      //                                 ),
                      //                           ),
                      //                           Text(
                      //                             'Industry Expert',
                      //                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      //                                   fontFamily: 'Inter',
                      //                                   color: Theme.of(context).textTheme.bodySmall?.color,
                      //                                   letterSpacing: 0.0,
                      //                                 ),
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     ),
                      //                     Icon(
                      //                       Icons.close,
                      //                       color: Theme.of(context).colorScheme.error,
                      //                       size: 20,
                      //                     ),
                      //                   ],
                      //                 ),
                      //                 const SizedBox(height: 12),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         const SizedBox(height: 12),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, 
                    child: ElevatedButton(
                      onPressed: () async {
                        LoggerService.logger.w('Button pressed ...');
                        Event event = Event(
                          name: _textController1.text.toString(),
                          description: _textController2.text.toString(),
                          targetAudience: _textController3.text.toString(),
                          location: _textController4.text.toString(),
                          type: choiceChipsValue!.toString(),
                          startDate: DateFormat('hh:mm a').parse(timeController.text.toString()),
                          endDate: DateFormat('dd/MM/yyyy').parse(endDateController.text.toString()),
                          banner: "123456789",
                          status: "Upcoming",
                          idCreate: ""
                        );
                        LoggerService.logger.w(event.toJson());
                        await createEvent(event, context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onPrimary, 
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontFamily: 'Inter Tight',
                              letterSpacing: 0.0,
                            ),
                        // padding: const EdgeInsets.symmetric(vertical: 16),
                        maximumSize: const Size(double.infinity, double.infinity),
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
        ),
      ),
    );
  }
}
