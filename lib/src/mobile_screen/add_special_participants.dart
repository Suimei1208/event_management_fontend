// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:event_management/src/service/event_service.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:flutter/material.dart';

class SpecialParticipantsPage extends StatefulWidget {
  final int eventId;
  const SpecialParticipantsPage({super.key, required this.eventId});

  @override
  _SpecialParticipantsPageState createState() =>
      _SpecialParticipantsPageState();
}

class _SpecialParticipantsPageState extends State<SpecialParticipantsPage> {
  List<Map<String, dynamic>> specialParticipants = [];
  List<Map<String, dynamic>> searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  Future<void> _fetchParticipants() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final participants = await fetchSpecialParticipants(widget.eventId);
      setState(() {
        specialParticipants = participants;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchUsers(String name) async {
    if (name.isEmpty) {
      setState(() {
        searchResults = [];
        _isSearching = false;
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

  void _addUserToParticipants(Map<String, dynamic> user) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.6,
        child: AddSpecialParticipantForm(
          eventId: widget.eventId,
          user: user,
          onParticipantAdded: (participant) {
            setState(() {
              specialParticipants.add(participant);
            });
          },
        ),
      ),
    );
  }

  Future<void> _removeParticipant(int participantId, int index) async {
    try {
      await removeSpecialParticipant(widget.eventId, participantId);
      setState(() {
        specialParticipants.removeAt(index);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove participant: $error')),
      );
    }
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_isSearching)
            const Center(child: CircularProgressIndicator())
          else if (searchResults.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Search Results',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final user = searchResults[index];
                        return ListTile(
                          leading: user['avtUrl'].isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(user['avtUrl']),
                                )
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(user['name']),
                          onTap: () {
                            _addUserToParticipants(user);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Special Guests',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: specialParticipants.isEmpty
                        ? const Center(
                            child: Text(
                              'No special participants yet.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: specialParticipants.length,
                            itemBuilder: (context, index) {
                              final participant = specialParticipants[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: participant['photoUrl'] != null
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              participant['photoUrl']),
                                        )
                                      : const CircleAvatar(
                                          child: Icon(Icons.person)),
                                  title: Text(participant['name']),
                                  subtitle: Text(participant['role']),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _removeParticipant(
                                        participant['id'], index),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AddSpecialParticipantForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onParticipantAdded;
  final int eventId;
  final Map<String, dynamic>? user;

  const AddSpecialParticipantForm({
    super.key,
    required this.onParticipantAdded,
    required this.eventId,
    this.user,
  });

  @override
  _AddSpecialParticipantFormState createState() =>
      _AddSpecialParticipantFormState();
}

class _AddSpecialParticipantFormState extends State<AddSpecialParticipantForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final List<String> _roles = ['Speaker', 'Special Guest'];
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final participant = {
        'name': widget.user!['name'],
        'role': _selectedRole!,
        'description': _descriptionController.text,
        'photoUrl': widget.user!['avtUrl'],
        'registration_Date': DateTime.now().toIso8601String(),
      };

      await addSpecialParticipant(
        eventId: widget.eventId,
        name: widget.user!['name'],
        role: _selectedRole!,
        description: _descriptionController.text,
        photoUrl: widget.user!['avtUrl'],
      );

      widget.onParticipantAdded(participant);
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add participant: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            if (widget.user != null) ...[
              ListTile(
                leading: widget.user!['avtUrl'].isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(widget.user!['avtUrl']),
                      )
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(widget.user!['name']),
              ),
            ],
            DropdownButtonFormField<String>(
              value: _selectedRole,
              hint: const Text('Select Role'),
              decoration: const InputDecoration(labelText: 'Role'),
              items: _roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a role';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Add Participant'),
                  ),
          ],
        ),
      ),
    );
  }
}
