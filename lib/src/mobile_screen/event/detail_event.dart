// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks
import 'dart:io';

import 'package:event_management/generated/l10n.dart';
import 'package:event_management/src/mobile_screen/event/request.dart';
import 'package:event_management/src/mobile_screen/event/schedules.dart';
import 'package:event_management/src/mobile_screen/event/update_event.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/notification_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/service/spending_service.dart';
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
  String averageParticipationTime = '';
  String participationPercentage = '';
  String userRole = "";

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
      averageParticipationTime = '';
      participationPercentage = '';
    });

    await _fetchUserId();
    await _loadEventData();
    await _loadUserRole();
    _loadSpendingData(widget.event.id);

    if (!mounted) return;
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

  Future<void> _loadUserRole() async {
    try {
      Participant? participant =
          await fetchParticipantRoleByUserIdAndEventId(widget.event.id);

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
    try {
      final eventData = await getEventData(widget.event.id);
      if (!mounted) return;
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
      });
    } catch (error) {
      LoggerService.logger.e(error);
      if (!mounted) return;
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

  String formatCurrency(double amount) {
    final format = NumberFormat("#,###", "vi_VN");
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final eventId = widget.event.id;
    final eventName = widget.event.name;
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        elevation: 0,
        actions: [
          if (userRole == "Host-${widget.event.id}" ||
              userRole == "Staff-${widget.event.id}")
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
          if (userRole == "Host-${widget.event.id}" ||
              userRole == "Staff-${widget.event.id}")
            IconButton(
              icon: const Icon(Icons.file_copy),
              onPressed: () {
                handleExcelUpload(eventId, eventName);
              },
            ),
          if (userRole == "Host-${widget.event.id}" ||
              userRole == "Staff-${widget.event.id}")
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => QuickActions(
                    userRole: userRole,
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
                          width: 400,
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
                  const SizedBox(height: 24),
                  _buildSpecialParticipantsSection(widget.event.id),
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

  Future<void> _loadSpendingData(int eventId) async {
    try {
      final fetchedData = await fetchSpendings(eventId);

      Map<String, double> incomeData = {};
      Map<String, double> expenseData = {};
      List<Map<String, dynamic>> history = [];

      for (var item in fetchedData) {
        if (item['type'] == 'Income') {
          incomeData[item['category']] = item['amount'].toDouble();
        } else if (item['type'] == 'Expense') {
          expenseData[item['category']] = item['amount'].toDouble();
        }

        history.add({
          'id': item['id'],
          'type': item['type'],
          'category': item['category'],
          'amount': item['amount'].toDouble(),
          'date': item['date'],
        });
      }
    } catch (e) {
      setState(() {});
      LoggerService.logger.e('Error loading data: $e');
    }
  }

  Widget _buildSpecialParticipantsSection(int eventId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchSpecialParticipants(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('This event has no special participants'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Special Participants",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('No special participants available for this event.'),
            ],
          );
        } else {
          final participants = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Special Participants",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
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
    return MouseRegion(
      onEnter: (_) {
        setState(() {});
      },
      onExit: (_) {
        setState(() {});
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(name),
        subtitle: Text(role),
        trailing: const Icon(Icons.info),
        onTap: () {
          _showDescriptionDialog(description);
        },
      ),
    );
  }

  void _showDescriptionDialog(String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Special participant description"),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
