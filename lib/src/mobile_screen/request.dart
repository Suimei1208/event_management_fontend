// ignore_for_file: use_build_context_synchronously

import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  final int id;

  const RequestPage({super.key, required this.id});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  Future<List<Participant>>? _pendingParticipants;

  // Fetch participants when the page loads
  @override
  void initState() {
    super.initState();
    _loadPendingParticipants();
  }

  void _loadPendingParticipants() {
    setState(() {
      _pendingParticipants = getPendingParticipants(widget.id);
    });
  }

  Future<void> _approveParticipant(int participantId) async {
    bool isApproved = await approveParticipant(widget.id, participantId);
    if (isApproved) {
      _loadPendingParticipants();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to approve participant')),
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
                          onPressed: () => _approveParticipant(participant.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            // Handle rejection if needed
                          },
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
