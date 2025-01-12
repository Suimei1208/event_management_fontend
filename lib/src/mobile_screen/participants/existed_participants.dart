// ignore_for_file: use_build_context_synchronously

import 'package:event_management/src/service/participants.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';

class ExistedParticipants extends StatefulWidget {
  final int id;

  const ExistedParticipants({super.key, required this.id});

  @override
  State<ExistedParticipants> createState() => _ExistedParticipantsState();
}

class _ExistedParticipantsState extends State<ExistedParticipants> {
  Future<List<Participant>>? _approvedParticipants;
  Future<List<Participant>>? _addedParticipants;
  List<Participant> _allApprovedParticipants = [];
  List<Participant> _allAddedParticipants = [];
  List<Participant> _filteredApprovedParticipants = [];
  List<Participant> _filteredAddedParticipants = [];

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  void _loadParticipants() {
    setState(() {
      _approvedParticipants =
          getParticipants(widget.id, "Approved", "Participant");
      _addedParticipants = getParticipants(widget.id, "Added", "Participant");
    });
  }

  Future<void> _removeParticipant(int participantId) async {
    try {
      bool isRemoved = await removeParticipant(widget.id, participantId);
      if (isRemoved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant removed successfully')),
        );
        _loadParticipants();
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

  void _filterParticipants(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredApprovedParticipants = _allApprovedParticipants
          .where((participant) =>
              participant.name.toLowerCase().contains(_searchQuery) ||
              participant.role.toLowerCase().contains(_searchQuery))
          .toList();

      _filteredAddedParticipants = _allAddedParticipants
          .where((participant) =>
              participant.name.toLowerCase().contains(_searchQuery) ||
              participant.role.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Existed Participants"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ParticipantSearchDelegate(
                  participants:
                      _allApprovedParticipants + _allAddedParticipants,
                  onSearch: _filterParticipants,
                  onRemove: _removeParticipant,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Approved Participants',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<List<Participant>>(
                    future: _approvedParticipants,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No approved participants.'));
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        _allApprovedParticipants = snapshot.data!;
                        _filteredApprovedParticipants =
                            _allApprovedParticipants;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredApprovedParticipants.length,
                          itemBuilder: (context, index) {
                            Participant participant =
                                _filteredApprovedParticipants[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(participant.photoUrl),
                                ),
                                title: Text(participant.name),
                                subtitle:
                                    Text('${participant.role} | Approved'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _removeParticipant(participant.id),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            // Added Participants Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Added Participants',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<List<Participant>>(
                    future: _addedParticipants,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No added participants.'));
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        _allAddedParticipants = snapshot.data!;
                        _filteredAddedParticipants = _allAddedParticipants;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredAddedParticipants.length,
                          itemBuilder: (context, index) {
                            Participant participant =
                                _filteredAddedParticipants[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(participant.photoUrl),
                                ),
                                title: Text(participant.name),
                                subtitle: Text('${participant.role} | Added'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _removeParticipant(participant.id),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantSearchDelegate extends SearchDelegate {
  final List<Participant> participants;
  final Function(String) onSearch;
  final Function(int) onRemove;

  ParticipantSearchDelegate({
    required this.participants,
    required this.onSearch,
    required this.onRemove,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return _buildResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResults();
  }

  Widget _buildResults() {
    final filteredParticipants = participants.where((participant) {
      return participant.name.toLowerCase().contains(query.toLowerCase()) ||
          participant.role.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredParticipants.length,
      itemBuilder: (context, index) {
        Participant participant = filteredParticipants[index];

        // Determine the status (approved or added)
        String status = participant
            .status; // Assuming 'status' is a field in the Participant model

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(participant.photoUrl),
          ),
          title: Text(participant.name),
          subtitle: Text('${participant.role} | $status'),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              onRemove(participant
                  .id); // Call the onRemove function to handle removal
            },
          ),
        );
      },
    );
  }
}
