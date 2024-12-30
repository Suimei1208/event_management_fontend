// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks
import 'package:event_management/src/mobile_screen/add_guest.dart';
import 'package:event_management/src/mobile_screen/request.dart';
import 'package:event_management/src/mobile_screen/schedules.dart';
import 'package:event_management/src/mobile_screen/update_event.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  bool isLoading = true;
  bool access = false;
  bool allowSelectSchedule = false;

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
      access = false;
      allowSelectSchedule = false;
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

  Future<void> _loadEventData() async {
    try {
      final eventData = await getEventData(widget.event.id);

      setState(() {
        access = eventData['data']['access'];
        allowSelectSchedule = eventData['data']['allowSelectSchedule'];
        eventName = eventData['data']['name'];
        description = eventData['data']['description'];
        location = eventData['data']['location'];
        startDate =
            "${DateFormat.jm().format(DateTime.parse(eventData['data']['startDate']))} - ${DateTime.parse(eventData['data']['startDate']).day}/${DateTime.parse(eventData['data']['startDate']).month}/${DateTime.parse(eventData['data']['startDate']).year}";
        endDate =
            "${DateFormat.jm().format(DateTime.parse(eventData['data']['endDate']))} - ${DateTime.parse(eventData['data']['endDate']).day}/${DateTime.parse(eventData['data']['endDate']).month}/${DateTime.parse(eventData['data']['endDate']).year}";
      });
      LoggerService.logger.i(access);
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

  @override
  Widget build(BuildContext context) {
    final eventId = widget.event.id;
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (userId == widget.event.idCreate)
            IconButton(
              icon: const Icon(Icons.tune, color: Colors.black),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildQuickActions(),
                );
              },
            ),
          if (userId == widget.event.idCreate)
            IconButton(
              icon: const Icon(Icons.insert_invitation_sharp,
                  color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RequestPage(id: eventId)),
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
                  Text(
                    'Event Name: $eventName',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Description: $description',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Location: $location',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Start Date: $startDate',
                  ),
                  Text(
                    'End Date: $endDate',
                  ),
                  const SizedBox(height: 24),
                  _buildEventStats(),
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
                      child: const Text(
                        "View Full Schedule",
                        style: TextStyle(fontSize: 16, color: Colors.white),
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

  Widget _buildQuickActions() {
    final eventId = widget.event.id;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Add Speaker and Guest Action Buttons
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.person_add, "Add Speaker",
                        () async {
                      final newGuests = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddMembersPage(name: "Speakers"),
                        ),
                      );

                      if (newGuests != null && newGuests.isNotEmpty) {
                        await addParticipant(newGuests, eventId, "Speaker");
                        Navigator.of(context).pop();
                        LoggerService.logger.i("Speaker added: $newGuests");
                      }
                    }),
                    _buildActionButton(Icons.person_add, "Add Guest", () async {
                      final newGuests = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddMembersPage(name: "Guests"),
                        ),
                      );

                      if (newGuests != null && newGuests.isNotEmpty) {
                        await addParticipant(newGuests, eventId, "Guest");
                        Navigator.of(context).pop();
                        LoggerService.logger.i("Guests added: $newGuests");
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Remove Speaker and Guest Action Buttons
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.edit, "Remove Speaker", () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => _buildEditGuest("Speaker"),
                      );
                    }),
                    _buildActionButton(Icons.edit, "Remove Guest", () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => _buildEditGuest("Guest"),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Accessibility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        updateEventAccess(eventId, true);
                      },
                      child: const Text('Enable'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        updateEventAccess(eventId, false);
                      },
                      child: const Text('Disable'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Register Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        updateEventAllow(eventId, true);
                      },
                      child: const Text('Enable'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        updateEventAllow(eventId, false);
                      },
                      child: const Text('Disable'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditGuest(String role) {
    return FutureBuilder<List<Participant>>(
      future: fetchParticipantsByEventIdAndRole(widget.event.id, role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No guests available for this event.'));
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Failed to load guests: ${snapshot.error}'));
        } else {
          List<Participant> participants = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: participants.length,
            itemBuilder: (context, index) {
              Participant guest = participants[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(guest.photoUrl),
                  ),
                  title: Text(guest.name),
                  subtitle: Text(guest.role),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool confirmDelete = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Delete $role"),
                          content: Text(
                              'Are you sure you want to delete ${guest.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await deleteParticipantsFromEvent(
                                    widget.event.id, guest.id, role);
                                Navigator.of(context).pop(true);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmDelete) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        LoggerService.logger.i(
                            '${guest.name} has been deleted from the event.');
                      }
                    },
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildEventStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
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
              _buildStat("250", "Registered"),
              _buildStat("12", "Speakers"),
              _buildStat("24", "Sessions"),
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

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, size: 28, color: Colors.deepPurple),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
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
    return Row(
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              role,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
