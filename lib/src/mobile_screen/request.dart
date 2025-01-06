// ignore_for_file: use_build_context_synchronously

import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  final int id;

  const RequestPage({super.key, required this.id});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  Future<List<Participant>>? _pendingParticipants;

  @override
  void initState() {
    super.initState();
    _loadPendingParticipants();
  }

  void _loadPendingParticipants() {
    setState(() {
      _pendingParticipants =
          getParticipants(widget.id, "Pending", "Participant");
    });
  }

  Future<void> _approveParticipant(int participantId, String userId) async {
    bool isApproved =
        await approveParticipant(widget.id, participantId, userId);
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
      bool isRemoved = await removeParticipant(widget.id, participantId);
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
        await approveParticipant(widget.id, participant.id, participant.userId);
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
      appBar: AppBar(
        title: const Text("Pending Requests"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _approveAllParticipants,
            tooltip: 'Approve All',
          ),
        ],
      ),
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
            // Build the list of participants dynamically
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Participant participant = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(participant.photoUrl),
                    ),
                    title: Text(participant.name),
                    subtitle: Text(participant.role),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approveParticipant(
                              participant.id, participant.userId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _removeParticipant(participant.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
