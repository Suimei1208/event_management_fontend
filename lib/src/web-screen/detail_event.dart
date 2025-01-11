// ignore_for_file: avoid_web_libraries_in_flutter, use_build_context_synchronously, unused_local_variable

import 'dart:async';
import 'dart:html' as html;

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/mobile_screen/event/update_event.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:event_management/widget/quick_actions.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailsPageWeb extends StatefulWidget {
  final int eventId;

  const EventDetailsPageWeb({super.key, required this.eventId});

  static const routeName = "/home/detail-event/";

  @override
  State<EventDetailsPageWeb> createState() => _EventDetailsPageWebState();
}

class _EventDetailsPageWebState extends State<EventDetailsPageWeb> {
  User? user = FirebaseAuth.instance.currentUser;
  String eventName = '';
  String description = '';
  String location = '';
  String startDate = '';
  String endDate = '';
  String photoUrl = '';
  bool isLoading = true;
  bool access = false;
  bool allowSelectSchedule = false;
  String userRole = "";
  String status = "";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    setState(() {
      eventName = '';
      description = '';
      location = '';
      startDate = '';
      endDate = '';
      photoUrl = '';
      status = '';
      access = false;
      allowSelectSchedule = false;
    });

    await _loadEventData();
    await _loadUserRole();

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadEventData() async {
    try {
      final eventData = await getEventData(widget.eventId);
      if (!mounted) return;
      setState(() {
        access = eventData['data']['access'];
        allowSelectSchedule = eventData['data']['allowSelectSchedule'];
        eventName = eventData['data']['name'];
        description = eventData['data']['description'];
        location = eventData['data']['location'];
        photoUrl = eventData['data']['banner'];
        status = eventData['data']['status'];
        startDate =
            "${DateFormat.jm().format(DateTime.parse(eventData['data']['startDate']))} - ${DateTime.parse(eventData['data']['startDate']).day}/${DateTime.parse(eventData['data']['startDate']).month}/${DateTime.parse(eventData['data']['startDate']).year}";
        endDate =
            "${DateFormat.jm().format(DateTime.parse(eventData['data']['endDate']))} - ${DateTime.parse(eventData['data']['endDate']).day}/${DateTime.parse(eventData['data']['endDate']).month}/${DateTime.parse(eventData['data']['endDate']).year}";
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load event data. Please try again.')),
      );
    }
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

  // Replace file picker for web with a file input element
  Future<void> handleExcelUpload(int eventId, String eventName) async {
    final result = await _pickFile();
    if (result != null) {
      final studentIds = await parseExcelFile(result);
      LoggerService.logger.i("Student Id Fetched: $studentIds");
      if (studentIds.isEmpty) {
        LoggerService.logger.e("No valid Student IDs found in the Excel file.");
        return;
      }

      List<String> userIds = [];
      for (var studentId in studentIds) {
        LoggerService.logger.i("Student Id Detail Event: $studentId");
        final user = await fetchUserByStudentId(studentId);
        userIds.add(user['id']);
      }

      if (userIds.isNotEmpty) {
        final success = await addParticipantsToEventByExcel(eventId, userIds);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Participants added successfully.')),
          );
        } else {
          LoggerService.logger.e("Failed to add participants.");
        }
      } else {
        LoggerService.logger.e("No valid users found to add as participants.");
      }
    }
  }

  // Handle file picking for web
  Future<html.File?> _pickFile() async {
    final input = html.FileUploadInputElement();
    input.accept = '.xlsx'; // Only accept .xlsx files
    input.click();
    final completer = Completer<html.File>();
    input.onChange.listen((e) {
      final files = input.files;
      if (files!.isEmpty) {
        completer.completeError("No file selected.");
        return;
      }

      // Read the selected file and create a File instance
      final reader = html.FileReader();
      reader.readAsArrayBuffer(files[0]);

      reader.onLoadEnd.listen((e) {
        final result = reader.result;
        if (result is List<int>) {
          final file = html.File([result], files[0].name);
          completer.complete(file);
        } else {
          completer.completeError("Failed to read the file.");
        }
      });
    });
    return completer.future;
  }

  Future<List<String>> parseExcelFile(html.File file) async {
    List<String> studentIds = [];

    final reader = html.FileReader();
    final completer = Completer<List<String>>();

    reader.readAsArrayBuffer(file);

    reader.onLoadEnd.listen((e) async {
      final result = reader.result;
      if (result is List<int>) {
        final excel = Excel.decodeBytes(result);

        for (var table in excel.tables.keys) {
          final rows = excel.tables[table]?.rows ?? [];

          for (var i = 1; i < rows.length; i++) {
            var studentId = rows[i][0]?.value?.toString();

            if (studentId != null && studentId.isNotEmpty) {
              studentIds.add(studentId);
            } else {
              LoggerService.logger.e("Invalid or empty Student ID in row $i.");
            }
          }
        }
      }
      completer.complete(studentIds);
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(eventName,
            style: const TextStyle(fontSize: 24)), // Larger title font size
        elevation: 0,
        actions: [
          if (userRole == "Host-${widget.eventId}" ||
              userRole == "Staff-${widget.eventId}")
            IconButton(
              icon: const Icon(Icons.insert_invitation_sharp,
                  size: 30), // Larger icon size
              onPressed: () {
                // Navigator.pushNamed(
                //   context,
                //   WebRequestPage.routeName,
                // );
              },
            ),
          if (userRole == "Host-${widget.eventId}" ||
              userRole == "Staff-${widget.eventId}")
            IconButton(
              icon: const Icon(Icons.file_copy, size: 30), // Larger icon size
              onPressed: () {
                handleExcelUpload(widget.eventId, eventName);
              },
            ),
          if (userRole == "Host-${widget.eventId}" ||
              userRole == "Staff-${widget.eventId}")
            IconButton(
              icon: const Icon(Icons.more_vert, size: 30), // Larger icon size
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => QuickActions(
                    userRole: userRole,
                    eventId: widget.eventId,
                    access: access,
                    allowSelectSchedule: allowSelectSchedule,
                    status: status,
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 40, vertical: 40), // Larger padding
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photoUrl.isNotEmpty)
                  Center(
                    child: Image.network(
                      photoUrl,
                      width: 800, // Larger image width
                      height: 400, // Larger image height
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20), // Increase spacing
                Text(
                  '${S.of(context).event_name}: $eventName',
                  style: const TextStyle(fontSize: 24), // Larger text size
                ),
                const SizedBox(height: 20), // Increase spacing
                Text(
                  '${S.of(context).desc} $description',
                  style: const TextStyle(fontSize: 20), // Larger text size
                ),
                const SizedBox(height: 20), // Increase spacing
                Text(
                  '${S.of(context).location}: $location',
                  style: const TextStyle(fontSize: 20), // Larger text size
                ),
                const SizedBox(height: 20), // Increase spacing
                Text(
                  '${S.of(context).start_date}: $startDate',
                  style: const TextStyle(fontSize: 20), // Larger text size
                ),
                const SizedBox(height: 20), // Increase spacing
                Text(
                  '${S.of(context).end_date}: $endDate',
                  style: const TextStyle(fontSize: 20), // Larger text size
                ),
                const SizedBox(height: 30), // Increase spacing
                _buildSpecialParticipantsSection(widget.eventId),
                const SizedBox(height: 30), // Increase spacing
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/schedules");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20), // Larger padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                    ),
                    child: Text(
                      S.of(context).view_schedule,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white), // Larger font size
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: userRole == "Host-${widget.eventId}"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UpdateEvent(eventId: widget.eventId)),
                );
                _initializeData();
              },
              backgroundColor: const Color.fromARGB(255, 142, 106, 199),
              child: const Icon(Icons.edit, size: 35), // Larger icon size
            )
          : null,
    );
  }

  // Build the special participants section
  Widget _buildSpecialParticipantsSection(int eventId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchSpecialParticipants(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('This event has no special participants',
                  style: TextStyle(fontSize: 22)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Special Participants",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold)), // Larger text size
              SizedBox(height: 20), // Increase spacing
              Text('No special participants available for this event.',
                  style: TextStyle(fontSize: 20)), // Larger text size
            ],
          );
        } else {
          final participants = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Special Participants",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold)), // Larger text size
              const SizedBox(height: 20), // Increase spacing
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  return _buildParticipantTile(
                    name: participant['name'] ?? 'Unknown',
                    role: participant['role'] ?? 'Unknown',
                    description: participant['description'] ?? "Unknown",
                    photoUrl: participant['photoUrl'],
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildParticipantTile({
    required String name,
    required String role,
    String? photoUrl,
    required String description,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null ? const Icon(Icons.person) : null,
      ),
      title:
          Text(name, style: const TextStyle(fontSize: 22)), // Larger text size
      subtitle:
          Text(role, style: const TextStyle(fontSize: 20)), // Larger text size
      trailing: const Icon(Icons.info, size: 30), // Larger icon size
      onTap: () {
        _showDescriptionDialog(description);
      },
    );
  }

  void _showDescriptionDialog(String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Special participant description",
              style: TextStyle(fontSize: 24)), // Larger title size
          content: Text(description,
              style: const TextStyle(fontSize: 20)), // Larger content size
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close',
                  style: TextStyle(fontSize: 20)), // Larger button text
            ),
          ],
        );
      },
    );
  }
}
