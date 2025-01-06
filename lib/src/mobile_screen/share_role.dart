// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:event_management/src/models/event_with_participants.dart';
import 'package:event_management/src/models/events.dart';
import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:flutter/material.dart';
import 'package:event_management/src/service/user_service.dart';

class ShareRolePage extends StatefulWidget {
  final Event event;
  const ShareRolePage({super.key, required this.event});

  @override
  _ShareRolePageState createState() => _ShareRolePageState();
}

class _ShareRolePageState extends State<ShareRolePage> {
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
        widget.event.id,
        'Approved',
        'Host-${widget.event.id}',
      );

      final staffParticipants = await getParticipants(
        widget.event.id,
        'Approved',
        'Staff-${widget.event.id}',
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
      await addParticipant(userId, widget.event.id, role);
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
      final success = await removeParticipant(widget.event.id, participantId);
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
                  _assignRole(user['id'], 'Host-${widget.event.id}');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Staff'),
                onTap: () {
                  _assignRole(user['id'], 'Staff-${widget.event.id}');
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
                  _assignRole(participant.userId, 'Host-${widget.event.id}');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Make Staff'),
                onTap: () {
                  _removeRole(participant.id);
                  _assignRole(participant.userId, 'Staff-${widget.event.id}');
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
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
          ),
          onChanged: _searchUsers,
        ),
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(Icons.search),
          )
        ],
      ),
      body: Column(
        children: [
          if (_isLoadingParticipants)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Hosts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...hosts.map((host) {
                    return ListTile(
                      leading: host.photoUrl.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(host.photoUrl),
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
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Staff',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Search Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isSearching)
                    const Center(child: CircularProgressIndicator())
                  else if (searchResults.isNotEmpty)
                    ...searchResults.map((user) {
                      return ListTile(
                        leading: user['avtUrl'].isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(user['avtUrl']),
                              )
                            : const CircleAvatar(child: Icon(Icons.person)),
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
    );
  }
}
