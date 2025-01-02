// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks
import 'dart:io';

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/mobile_screen/request.dart';
import 'package:event_management/src/mobile_screen/schedules.dart';
import 'package:event_management/src/mobile_screen/update_event.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/notification_service.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:event_management/widget/quick_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  User? user = FirebaseAuth.instance.currentUser;
  String? userId;
  String eventName = '';
  String description = '';
  String targetAudience = '';
  String location = '';
  String startDate = '';
  String endDate = '';
  String photoUrl = '';
  bool isLoading = true;
  bool access = false;
  bool allowSelectSchedule = false;
  String registered = '';
  String speakers = '';
  String sessions = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      eventName = '';
      description = '';
      targetAudience = '';
      location = '';
      startDate = '';
      endDate = '';
      photoUrl = '';
      access = false;
      allowSelectSchedule = false;
      registered = '';
      speakers = '';
      sessions = '';
    });

    await _fetchUserId();
    await _loadEventData();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEventData();
  }

  Future<List<String>> parseExcelFile() async {
    List<String> studentIds = [];

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      final bytes = File(result.files.single.path!).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

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
    } else {
      LoggerService.logger.e("No file selected.");
    }
    return studentIds;
  }

  Future<void> _loadEventData() async {
    try {
      final eventData = await getEventData(widget.event.id);
      final stats = await getStats(widget.event.id);
      setState(() {
        access = eventData['data']['access'];
        allowSelectSchedule = eventData['data']['allowSelectSchedule'];
        eventName = eventData['data']['name'];
        description = eventData['data']['description'];
        location = eventData['data']['location'];
        photoUrl = eventData['data']['banner'];
        startDate =
            "${DateFormat.jm().format(DateTime.parse(eventData['data']['startDate']))} - ${DateTime.parse(eventData['data']['startDate']).day}/${DateTime.parse(eventData['data']['startDate']).month}/${DateTime.parse(eventData['data']['startDate']).year}";
        endDate =
            "${DateFormat.jm().format(DateTime.parse(eventData['data']['endDate']))} - ${DateTime.parse(eventData['data']['endDate']).day}/${DateTime.parse(eventData['data']['endDate']).month}/${DateTime.parse(eventData['data']['endDate']).year}";
        registered = stats['registered'].toString();
        speakers = stats['speaker'].toString();
        sessions = stats['sessions'].toString();
      });
    } catch (error) {
      LoggerService.logger.e(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load event data. Please try again.')),
      );
    }
  }

  Future<void> _fetchUserId() async {
    try {
      userId = await GetIdUser();
    } catch (e) {
      LoggerService.logger.e("Failed to fetch user id: $e");
    }
  }

  Future<void> _refreshEventData() async {
    await _initializeData();
  }

  void handleExcelUpload(int eventId, String eventName) async {
    final studentIds = await parseExcelFile();

    if (studentIds.isEmpty) {
      LoggerService.logger.e("No valid Student IDs found in the Excel file.");
      return;
    }

    List<String> userIds = [];
    for (var studentId in studentIds) {
      final user = await fetchUserByStudentId(studentId);
      userIds.add(user['id']);
    }

    if (userIds.isNotEmpty) {
      final success = await addParticipantsToEventByExcel(eventId, userIds);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participants added successfully.')),
        );
        LoggerService.logger.i("Participants added successfully: $userIds");
        String title = "Congratulation <3!";
        String body = "You have been added to the event: $eventName.";
        String topic = "event_${eventId}_$eventName";

        try {
          await sendNotification(title, body, topic);
          LoggerService.logger.i("Notification sent successfully.");
        } catch (e) {
          LoggerService.logger.e("Failed to send notification: $e");
        }
      } else {
        LoggerService.logger.e("Failed to add participants.");
      }
    } else {
      LoggerService.logger.e("No valid users found to add as participants.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventId = widget.event.id;
    final eventName = widget.event.name;
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (userId == widget.event.idCreate)
            IconButton(
              icon: const Icon(
                Icons.insert_invitation_sharp,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RequestPage(id: eventId)),
                );
              },
            ),
          // if (userId == widget.event.idCreate)
          //   IconButton(
          //     icon: const Icon(Icons.person),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => ExistedParticipants(id: eventId)),
          //       );
          //     },
          //   ),
          if (userId == widget.event.idCreate)
            IconButton(
              icon: const Icon(Icons.file_copy),
              onPressed: () {
                handleExcelUpload(eventId, eventName);
              },
            ),
          if (userId == widget.event.idCreate)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => QuickActions(
                    eventId: widget.event.id,
                    access: access,
                    allowSelectSchedule: allowSelectSchedule,
                    status: widget.event.status,
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshEventData,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  photoUrl.isNotEmpty
                      ? Image.network(
                          photoUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  Text(
                    '${S.of(context).event_name}: $eventName',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${S.of(context).desc} $description',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${S.of(context).location}: $location',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${S.of(context).start_date}: $startDate',
                  ),
                  Text(
                    '${S.of(context).end_date}: $endDate',
                  ),
                  const SizedBox(height: 24),
                  _buildEventStats(registered, speakers, sessions),
                  const SizedBox(height: 24),
                  _buildFeaturedParticipant("Speaker"),
                  const SizedBox(height: 8),
                  _buildFeaturedParticipant("Guest"),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SchedulesWidget(
                                    event: widget.event,
                                    isRegistered: allowSelectSchedule,
                                  )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        S.of(context).view_schedule,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: userId == widget.event.idCreate
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdateEvent(eventId: eventId)),
                );
                _initializeData();
              },
              backgroundColor: const Color.fromARGB(255, 142, 106, 199),
              child: const Icon(Icons.edit, size: 28),
            )
          : null,
    );
  }

  Widget _buildEventStats(String registered, String speakers, String sessions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "Event Stats",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(registered, "Registered"),
              _buildStat(speakers, "Speakers"),
              _buildStat(sessions, "Sessions"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedParticipant(String role) {
    return FutureBuilder<List<Participant>>(
      future: fetchParticipantsByEventIdAndRole(widget.event.id, role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Featured ${role}s",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('No ${role}s available for this event.'),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load ${role}s: ${snapshot.error}'),
          );
        } else {
          List<Participant> participants = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Featured ${role}s",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              for (var participant in participants)
                _buildSpeaker(
                    participant.name, participant.role, participant.photoUrl),
            ],
          );
        }
      },
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSpeaker(String name, String role, String imageUrl) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  role,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
