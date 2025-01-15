// ignore_for_file: avoid_web_libraries_in_flutter, use_build_context_synchronously, unused_local_variable

import 'dart:async';
import 'dart:html' as html;

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
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
    await _loadUserRole();
    await _loadEventData();

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
          LoggerService.logger.i("Role: $userRole");
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

  Future<html.File?> _pickFile() async {
    final input = html.FileUploadInputElement();
    input.accept = '.xlsx';
    input.click();
    final completer = Completer<html.File>();
    input.onChange.listen((e) {
      final files = input.files;
      if (files!.isEmpty) {
        completer.completeError("No file selected.");
        return;
      }

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
    bool isHostOrStaff = userRole == "Host-${widget.eventId}" ||
        userRole == "Staff-${widget.eventId}";

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Row(
        children: [
          // Sidebar
          if (isHostOrStaff)
            Card(
              child: Container(
                width: 350,
                // color: Colors.deepPurple.shade50,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSidebarButton(
                        Icons.file_copy, S.of(context).add_via_excel, () {
                      handleExcelUpload(widget.eventId, eventName);
                    }),
                    _buildSidebarButton(Icons.insert_invitation,
                        S.of(context).registration_list, () {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/pending-requests");
                    }),
                    _buildSidebarButton(
                        Icons.edit, S.of(context).edit_special_participants,
                        () {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/special-participants");
                    }),
                    _buildSidebarButton(
                        Icons.person, S.of(context).participant_list, () {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/existed-participants");
                    }),
                    _buildSidebarButton(
                        Icons.description, S.of(context).document, () {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/documents");
                    }),
                    _buildSidebarButton(Icons.share, S.of(context).share_role,
                        () {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/share-roles");
                    }),
                    _buildSidebarButton(
                        Icons.money_outlined, S.of(context).spending, () {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/spending");
                    }),
                    _buildSidebarButton(Icons.analytics, S.of(context).stat,
                        () {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/event-analystics");
                    }),
                    _buildSidebarButton(
                        Icons.cancel_presentation, S.of(context).cancel_list,
                        () {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/list-cancelled-users");
                    }),
                    _buildSidebarButton(Icons.login, "CheckIn", () async {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/check-in");
                    }),
                    _buildSidebarButton(Icons.logout, "CheckOut", () async {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/check-out");
                    }),
                    _buildSidebarButton(Icons.edit, S.of(context).edit_event,
                        () {
                      Navigator.pushNamed(context,
                          "/home/detail-event/${widget.eventId}/edit-event");
                    }),
                    status != "Cancelled"
                        ? _buildSidebarButton(
                            Icons.cancel, S.of(context).cancel_event, () async {
                            cancelEvent(widget.eventId, context);
                          })
                        : _buildSidebarButton(
                            Icons.repeat_outlined, S.of(context).reopen, () {
                            resetEvent(widget.eventId, context);
                          }),
                  ],
                ),
              ),
            ),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 20), // Adjusted padding
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Photo
                    if (photoUrl.isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(16), // Rounded corners
                          child: Image.network(
                            photoUrl,
                            width: double.infinity, // Make it responsive
                            height: 250, // Adjusted height
                            fit: BoxFit
                                .contain, // Make the image fill its container
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Event Name
                    Text(
                      '${S.of(context).event_name}: $eventName',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple, // Enhanced color
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Event Description
                    Text(
                      '${S.of(context).desc}: $description',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Event Location
                    Text(
                      '${S.of(context).location}: $location',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Event Start Date
                    Text(
                      '${S.of(context).start_date}: $startDate',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Event End Date
                    Text(
                      '${S.of(context).end_date}: $endDate',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Special Participants Section
                    _buildSpecialParticipantsSection(widget.eventId),
                    const SizedBox(height: 30),

                    // View Schedule Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            "/home/detail-event/${widget.eventId}/schedules",
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5, // Add shadow for depth
                            backgroundColor: Colors.purple),
                        child: Text(
                          S.of(context).view_schedule,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                Colors.white, // Ensuring text color is legible
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper method for creating sidebar buttons
  Widget _buildSidebarButton(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.deepPurple),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).special_guest,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('No special participants available for this event.',
                  style: TextStyle(fontSize: 20)),
            ],
          );
        } else {
          final participants = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Special Participants",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
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
      title: Text(name, style: const TextStyle(fontSize: 22)),
      subtitle: Text(role, style: const TextStyle(fontSize: 20)),
      trailing: const Icon(Icons.info, size: 30),
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
          title: const Text("Info", style: TextStyle(fontSize: 24)),
          content: Text(description, style: const TextStyle(fontSize: 20)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }
}
