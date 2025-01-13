// ignore_for_file: use_build_context_synchronously

import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';

class RequestPageWeb extends StatefulWidget {
  final int eventId;
  const RequestPageWeb({super.key, required this.eventId});

  static const routeName = "/home/detail-event/pending-requests";

  @override
  State<RequestPageWeb> createState() => _RequestPageWebState();
}

class _RequestPageWebState extends State<RequestPageWeb> {
  Future<List<Participant>>? _pendingParticipants;
  String userRole = "";

  @override
  void initState() {
    super.initState();
    _loadPendingParticipants();
  }

  void _loadPendingParticipants() {
    setState(() {
      _pendingParticipants =
          getParticipants(widget.eventId, "Pending", "Participant");
    });
  }

  Future<void> _approveParticipant(int participantId, String userId) async {
    bool isApproved =
        await approveParticipant(widget.eventId, participantId, userId);
    if (isApproved) {
      _loadPendingParticipants();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to approve participant')),
      );
    }
  }

  Future<void> _removeParticipant(int participantId) async {
    try {
      bool isRemoved = await removeParticipant(widget.eventId, participantId);
      if (isRemoved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant removed successfully')),
        );
        _loadPendingParticipants();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove participant')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _approveAllParticipants() async {
    if (_pendingParticipants != null) {
      List<Participant> participants = await _pendingParticipants!;
      for (var participant in participants) {
        await approveParticipant(
            widget.eventId, participant.id, participant.userId);
      }
      _loadPendingParticipants();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All participants approved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: FutureBuilder<List<Participant>>(
        future: _pendingParticipants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pending participants found.'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Participant> participants = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _approveAllParticipants,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Approve All',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 1,
                        child: DataTable(
                          columnSpacing:
                              480.0, // Increase spacing between columns
                          columns: const [
                            DataColumn(label: Text('Photo')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Role')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: participants.map((participant) {
                            return DataRow(cells: [
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0), // Row spacing
                                  child: CircleAvatar(
                                    radius: 30, // Larger circle for the photo
                                    backgroundImage:
                                        NetworkImage(participant.photoUrl),
                                  ),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Text(
                                    participant.name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Text(
                                    participant.role,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Colors.green),
                                      tooltip: 'Approve',
                                      onPressed: () => _approveParticipant(
                                          participant.id, participant.userId),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      tooltip: 'Remove',
                                      onPressed: () =>
                                          _removeParticipant(participant.id),
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
