// ignore_for_file: use_build_context_synchronously
import 'package:event_management/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';

class ScheduleParticipants extends StatefulWidget {
  final int id;

  const ScheduleParticipants({super.key, required this.id});

  @override
  State<ScheduleParticipants> createState() => _ExistedParticipantsState();
}

class _ExistedParticipantsState extends State<ScheduleParticipants> {
  Future<List<Participant>>? _approvedParticipants;
  List<Participant> _allApprovedParticipants = [];
  List<Participant> _filteredApprovedParticipants = [];

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  void _loadParticipants() {
    setState(() {
      _approvedParticipants = getScheduleParticipants(widget.id, "Participant");
    });
  }

  void _filterParticipants(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredApprovedParticipants = _allApprovedParticipants
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
        title: Text(S.of(context).schedule_participant_list),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ParticipantSearchDelegate(
                  participants: _allApprovedParticipants,
                  onSearch: _filterParticipants,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<Participant>>(
                future: _approvedParticipants,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No Schedule participants.'));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    _allApprovedParticipants = snapshot.data!;
                    _filteredApprovedParticipants = _allApprovedParticipants;
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
      ),
    );
  }
}

class ParticipantSearchDelegate extends SearchDelegate {
  final List<Participant> participants;
  final Function(String) onSearch;

  ParticipantSearchDelegate({
    required this.participants,
    required this.onSearch,
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
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(participant.photoUrl),
          ),
          title: Text(participant.name),
          subtitle: Text('${participant.role} | Approved'),
        );
      },
    );
  }
}
