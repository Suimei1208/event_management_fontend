// ignore_for_file: use_build_context_synchronously

import 'package:event_management/src/mobile_screen/add_guest.dart';
import 'package:event_management/src/mobile_screen/existed_participants.dart';
import 'package:event_management/src/mobile_screen/list_users_cancel.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:flutter/material.dart';

class QuickActions extends StatefulWidget {
  final int eventId;
  final bool access;
  final bool allowSelectSchedule;
  final String status;

  const QuickActions({
    super.key,
    required this.eventId,
    required this.access,
    required this.allowSelectSchedule,
    required this.status,
  });

  @override
  // ignore: library_private_types_in_public_api
  _QuickActionsState createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  late bool access;
  late bool allowSelectSchedule;

  @override
  void initState() {
    super.initState();
    access = widget.access;
    allowSelectSchedule = widget.allowSelectSchedule;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.grey.shade100,
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
                        await addParticipant(
                            newGuests, widget.eventId, "Speaker");
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
                        await addParticipant(
                            newGuests, widget.eventId, "Guest");
                        Navigator.of(context).pop();
                        LoggerService.logger.i("Guests added: $newGuests");
                      }
                    }),
                    _buildActionButton(Icons.share, "Share Role", () {}),
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
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    widget.status != "Cancelled"
                        ? _buildActionButton(Icons.cancel, "Cancel Event",
                            () async {
                            cancelEvent(widget.eventId, context);
                          })
                        : _buildActionButton(
                            Icons.repeat_outlined, "Mở lại Event", () {
                            resetEvent(widget.eventId, context);
                          }),
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

          // Remove Speaker and Guest Action Buttons
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.person, "Quản lý người tham gia",
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ExistedParticipants(id: widget.eventId)),
                      );
                    }),
                    _buildActionButton(
                        Icons.description, "Documents", () async {}),
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
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                        Icons.money_outlined, "Chi Tiêu", () async {}),
                    _buildActionButton(
                        Icons.cancel_presentation, "Dữ liệu hủy tham gia", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CancelledUsersScreen()),
                      );
                    }),
                    _buildActionButton(Icons.analytics, "Statistics", () {}),
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
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Accessibility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: access,
                  onChanged: (bool value) async {
                    setState(() {
                      access = value;
                    });

                    await updateEventAccess(widget.eventId, value);
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Register Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
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
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildEditGuest(String role) {
    return FutureBuilder<List<Participant>>(
      future: fetchParticipantsByEventIdAndRole(widget.eventId, role),
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
                                    widget.eventId, guest.id, role);
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
}
