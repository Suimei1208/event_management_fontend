// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/service/user_service.dart';

class WebShareRolePage extends StatefulWidget {
  final int eventId;
  const WebShareRolePage({super.key, required this.eventId});

  @override
  _ShareRolePageState createState() => _ShareRolePageState();
}

class _ShareRolePageState extends State<WebShareRolePage> {
  List<Map<String, dynamic>> searchResults = [];
  List<Participant> hosts = [];
  List<Participant> staff = [];
  bool _isLoadingParticipants = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  Future<void> _fetchParticipants() async {
    try {
      setState(() {
        _isLoadingParticipants = true;
      });

      final hostParticipants = await getParticipants(
        widget.eventId,
        'Approved',
        'Host-${widget.eventId}',
      );

      final staffParticipants = await getParticipants(
        widget.eventId,
        'Approved',
        'Staff-${widget.eventId}',
      );

      setState(() {
        hosts = hostParticipants;
        staff = staffParticipants;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch participants: $error')),
      );
    } finally {
      setState(() {
        _isLoadingParticipants = false;
      });
    }
  }

  Future<void> _assignRole(String userId, String role) async {
    try {
      await addParticipant(userId, widget.eventId, role);
      await _fetchParticipants();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role assigned successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign role: $error')),
      );
    }
  }

  Future<void> _removeRole(int participantId) async {
    try {
      final success = await removeParticipant(widget.eventId, participantId);
      if (success) {
        await _fetchParticipants();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant removed successfully')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove participant: $error')),
      );
    }
  }

  Future<void> _searchUsers(String name) async {
    if (name.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await searchUser(name);
      setState(() {
        searchResults = results;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $error')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _selectUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Role to ${user['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Host'),
                onTap: () {
                  _assignRole(user['id'], 'Host-${widget.eventId}');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Staff'),
                onTap: () {
                  _assignRole(user['id'], 'Staff-${widget.eventId}');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _modifyParticipantRole(Participant participant) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modify Role for ${participant.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Make Host'),
                onTap: () {
                  _removeRole(participant.id);
                  _assignRole(participant.userId, 'Host-${widget.eventId}');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Make Staff'),
                onTap: () {
                  _removeRole(participant.id);
                  _assignRole(participant.userId, 'Staff-${widget.eventId}');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Remove Role'),
                onTap: () {
                  _removeRole(participant.id);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar Section
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: _searchUsers,
                ),
                const SizedBox(height: 20),

                // Hosts Section
                if (_isLoadingParticipants)
                  const Center(child: CircularProgressIndicator())
                else
                  Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          'Hosts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...hosts.map((host) {
                          return ListTile(
                            leading: host.photoUrl.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(host.photoUrl),
                                  )
                                : const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(host.name),
                            subtitle: const Text('Host'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _modifyParticipantRole(host);
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 20),

                        // Staff Section
                        const Text(
                          'Staff',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...staff.map((staffMember) {
                          return ListTile(
                            leading: staffMember.photoUrl.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(staffMember.photoUrl),
                                  )
                                : const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(staffMember.name),
                            subtitle: const Text('Staff'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _modifyParticipantRole(staffMember);
                              },
                            ),
                          );
                        }),
                        const Divider(),

                        // Search Results Section
                        const Text(
                          'Search Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_isSearching)
                          const Center(child: CircularProgressIndicator())
                        else if (searchResults.isNotEmpty)
                          ...searchResults.map((user) {
                            return ListTile(
                              leading: user['avtUrl'].isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user['avtUrl']),
                                    )
                                  : const CircleAvatar(
                                      child: Icon(Icons.person)),
                              title: Text(user['name']),
                              onTap: () {
                                _selectUser(user);
                              },
                            );
                          })
                        else
                          const Center(child: Text('No results found')),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
