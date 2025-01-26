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
  List<Map<String, dynamic>> specialParticipants = [];

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
      specialParticipants = [];
    });
    await _loadUserRole();
    await _loadEventData();
    await _loadSpecialParticipants();

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadSpecialParticipants() async {
    try {
      final participants = await fetchSpecialParticipants(widget.eventId);
      if (!mounted) return;

      setState(() {
        specialParticipants = participants;
      });
    } catch (e) {
      LoggerService.logger.e("Error fetching special participants: $e");
    }
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
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSidebarButton(
                            Icons.file_copy, S.of(context).add_via_excel, () {
                          handleExcelUpload(widget.eventId, eventName);
                        }),
                        const SizedBox(height: 16),
                        _buildSidebarButton(Icons.insert_invitation,
                            S.of(context).registration_list, () {
                          Navigator.pushNamed(context,
                              "/home/detail-event/${widget.eventId}/pending-requests");
                        }),
                        const SizedBox(height: 16),
                        _buildSidebarButton(
                            Icons.edit, S.of(context).edit_special_participants,
                            () {
                          Navigator.pushNamed(context,
                              "/home/detail-event/${widget.eventId}/special-participants");
                        }),
                        const SizedBox(height: 16),
                        _buildSidebarButton(
                            Icons.person, S.of(context).participant_list, () {
                          Navigator.pushNamed(context,
                              "/home/detail-event/${widget.eventId}/existed-participants");
                        }),
                        const SizedBox(height: 16),
                        _buildSidebarButton(
                            Icons.description, S.of(context).document, () {
                          Navigator.pushNamed(context,
                              "/home/detail-event/${widget.eventId}/documents");
                        }),
                        const SizedBox(height: 16),
                        _buildSidebarButton(
                            Icons.share, S.of(context).share_role, () {
                          Navigator.pushNamed(context,
                              "/home/detail-event/${widget.eventId}/share-roles");
                        }),
                        const SizedBox(height: 16),
                        _buildSidebarButton(
                            Icons.money_outlined, S.of(context).spending, () {
                          Navigator.pushNamed(context,
                              "/home/detail-event/${widget.eventId}/spending");
                        }),
                        const SizedBox(height: 16),
                        _buildSidebarButton(Icons.analytics, S.of(context).stat,
                            () {
                          Navigator.pushNamed(context,
                              "/home/detail-event/${widget.eventId}/event-analystics");
                        }),
                        const SizedBox(height: 16),
                        _buildSidebarButton(Icons.cancel_presentation,
                            S.of(context).cancel_list, () {
                          Navigator.pushNamed(context,
                              "/home/detail-event/${widget.eventId}/list-cancelled-users");
                        }),
                        const SizedBox(height: 16),
                        _buildSidebarButton(Icons.login, "CheckIn", () async {
                          Navigator.pushNamed(context,
                              "/home/detail-event/${widget.eventId}/check-in");
                        }),
                        const SizedBox(height: 16),
                        _buildSidebarButton(Icons.logout, "CheckOut", () async {
                          Navigator.pushNamed(context,
                              "/home/detail-event/${widget.eventId}/check-out");
                        }),
                        const SizedBox(height: 16),
                        _buildSidebarButton(
                            Icons.edit, S.of(context).edit_event, () {
                          Navigator.pushNamed(context,
                              "/home/detail-event/${widget.eventId}/edit-event");
                        }),
                        const SizedBox(height: 16),
                        status != "Cancelled"
                            ? _buildSidebarButton(
                                Icons.cancel, S.of(context).cancel_event,
                                () async {
                                cancelEvent(widget.eventId, context);
                              })
                            : _buildSidebarButton(
                                Icons.repeat_outlined, S.of(context).reopen,
                                () {
                                resetEvent(widget.eventId, context);
                              }),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSidebarButton(Icons.accessibility_new,
                                S.of(context).accessibility, () {}),
                            Transform.scale(
                              scale: MediaQuery.of(context).size.width * 0.0006,
                              child: Switch(
                                value: access,
                                onChanged: (bool value) async {
                                  setState(() {
                                    access = value;
                                  });

                                  await updateEventAccess(
                                      widget.eventId, value);
                                },
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.grey,
                                inactiveTrackColor: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSidebarButton(Icons.schedule,
                                S.of(context).register_schedule, () {}),
                            Transform.scale(
                              scale: MediaQuery.of(context).size.width * 0.0006,
                              child: Switch(
                                value: allowSelectSchedule,
                                onChanged: (bool value) async {
                                  setState(() {
                                    allowSelectSchedule = value;
                                  });

                                  await updateEventAllow(widget.eventId, value);
                                },
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.grey,
                                inactiveTrackColor: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Photo
                    if (photoUrl.isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            photoUrl,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.contain,
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
                        color: Colors.deepPurple,
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
                    _buildSpecialParticipantsSection(),
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
                            elevation: 5,
                            backgroundColor: Colors.purple),
                        child: Text(
                          S.of(context).view_schedule,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildSidebarButton(
      IconData icon, String label, VoidCallback onPressed) {
    double screenWidth = MediaQuery.of(context).size.width;

    double iconSize = screenWidth * 0.015;
    double fontSize = screenWidth * 0.01;

    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: MaterialButton(
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        hoverColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: iconSize),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontSize: fontSize),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          S.of(context).special_guest,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (specialParticipants.isEmpty)
          const Text("No Special participants")
        else
          ...specialParticipants.map((participant) {
            return _buildParticipantTile(
              name: participant['name'],
              role: participant['role'],
              photoUrl: participant['photoUrl'],
              description: participant['description'],
            );
          }),
      ],
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
