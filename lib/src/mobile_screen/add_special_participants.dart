// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:event_management/src/service/event_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SpecialParticipantsPage extends StatefulWidget {
  final int eventId;
  const SpecialParticipantsPage({super.key, required this.eventId});

  @override
  _SpecialParticipantsPageState createState() =>
      _SpecialParticipantsPageState();
}

class _SpecialParticipantsPageState extends State<SpecialParticipantsPage> {
  List<Map<String, dynamic>> specialParticipants = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  Future<void> _fetchParticipants() async {
    try {
      final participants = await fetchSpecialParticipants(widget.eventId);
      setState(() {
        specialParticipants = participants;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Participants'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSpecialParticipant,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : specialParticipants.isEmpty
              ? const Center(
                  child: Text(
                    'Currently no special participants',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                backgroundImage:
                                    NetworkImage(participant['photoUrl']),
                              )
                            : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(participant['name']),
                        subtitle: Text(participant['role']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _removeParticipant(participant['id'], index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _addSpecialParticipant() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AddSpecialParticipantForm(
        onParticipantAdded: (participant) {
          setState(() {
            specialParticipants.add(participant);
          });
        },
        eventId: widget.eventId,
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
}

class AddSpecialParticipantForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onParticipantAdded;
  final int eventId;

  const AddSpecialParticipantForm({
    super.key,
    required this.onParticipantAdded,
    required this.eventId,
  });

  @override
  _AddSpecialParticipantFormState createState() =>
      _AddSpecialParticipantFormState();
}

class _AddSpecialParticipantFormState extends State<AddSpecialParticipantForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _roles = ['Speaker', 'Special Guest'];
  String? _selectedRole;

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to handle form submission and image upload
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fileName =
          '${_nameController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final photoUrl = await uploadImageEventToImageKit(
          _selectedImage!, widget.eventId, fileName);

      final participant = {
        'name': _nameController.text,
        'role': _roleController.text,
        'description': _descriptionController.text,
        'photoUrl': photoUrl,
        'registration_Date': DateTime.now().toIso8601String(),
      };

      await addSpecialParticipant(
        eventId: widget.eventId,
        name: _nameController.text,
        role: _roleController.text,
        description: _descriptionController.text,
        photoUrl: photoUrl,
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
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
            const SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(_selectedImage!)
                : const Text('No image selected'),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
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
