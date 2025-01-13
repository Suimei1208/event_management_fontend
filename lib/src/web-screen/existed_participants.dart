// ignore_for_file: use_build_context_synchronously

import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';

class ExistedParticipantsWeb extends StatefulWidget {
  final int eventId;

  const ExistedParticipantsWeb({super.key, required this.eventId});
  static const routeName = "/home/event-detail/existed-participants";
  @override
  State<ExistedParticipantsWeb> createState() => _ExistedParticipantsWebState();
}

class _ExistedParticipantsWebState extends State<ExistedParticipantsWeb> {
  String userRole = "";
  Future<List<Participant>>? _approvedParticipants;
  Future<List<Participant>>? _addedParticipants;

  final List<Participant> _allApprovedParticipants = [];
  final List<Participant> _allAddedParticipants = [];

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  void _loadParticipants() {
    _approvedParticipants =
        getParticipants(widget.eventId, "Approved", "Participant");
    _addedParticipants =
        getParticipants(widget.eventId, "Added", "Participant");
  }

  Future<void> _removeParticipant(int participantId) async {
    try {
      bool isRemoved = await removeParticipant(widget.eventId, participantId);
      if (isRemoved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant removed successfully')),
        );
        _loadParticipants();
        setState(() {});
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

  List<Participant> _filterParticipants(
      List<Participant> participants, String query) {
    if (query.isEmpty) return participants;
    return participants
        .where((participant) =>
            participant.name.toLowerCase().contains(query.toLowerCase()) ||
            participant.role.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Search Participants',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildParticipantList(
                              title: 'Approved Participants',
                              participantsFuture: _approvedParticipants,
                              allParticipants: _allApprovedParticipants),
                          const SizedBox(height: 20),
                          _buildParticipantList(
                              title: 'Added Participants',
                              participantsFuture: _addedParticipants,
                              allParticipants: _allAddedParticipants),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantList({
    required String title,
    required Future<List<Participant>>? participantsFuture,
    required List<Participant> allParticipants,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Participant>>(
          future: participantsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No $title.'));
            } else {
              allParticipants.clear();
              allParticipants.addAll(snapshot.data!);

              final filteredParticipants =
                  _filterParticipants(allParticipants, _searchQuery);

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredParticipants.length,
                itemBuilder: (context, index) {
                  Participant participant = filteredParticipants[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(participant.photoUrl),
                      ),
                      title: Text(participant.name),
                      subtitle: Text('${participant.role} | $title'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _removeParticipant(participant.id),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}
