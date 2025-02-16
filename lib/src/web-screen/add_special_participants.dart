// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_web_libraries_in_flutter, unused_field, deprecated_member_use

import 'dart:io';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/participants.dart';
import 'package:event_management/src/service/user_service.dart';
import 'package:event_management/src/service/user_service_web.dart';
import 'package:event_management/src/web-screen/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class WebSpecialParticipantsPage extends StatefulWidget {
  final int eventId;
  const WebSpecialParticipantsPage({super.key, required this.eventId});
  static const routeName = "/home/event-detail/special-participants";
  @override
  _SpecialParticipantsPageState createState() =>
      _SpecialParticipantsPageState();
}

class _SpecialParticipantsPageState extends State<WebSpecialParticipantsPage> {
  String userRole = "";
  List<Map<String, dynamic>> _participants = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
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
              _participants.add(participant);
            });
          },
        ),
      ),
    );
  }

  Future<void> _fetchParticipants() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final participant = await fetchSpecialParticipants(widget.eventId);
      setState(() {
        _participants = participant;
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
      LoggerService.logger.i(results);
      setState(() {
        searchResults = results.where((result) {
          // Filter to ensure we have the `name` field
          return result['name'] != null;
        }).toList();
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

  Future<void> _removeParticipant(int participantId, int index) async {
    try {
      await removeSpecialParticipant(widget.eventId, participantId);
      setState(() {
        _participants.removeAt(index);
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
      appBar: const CustomAppBar(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search users...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: _searchUsers,
                ),
              ),
              if (_isSearching)
                const Center(child: CircularProgressIndicator())
              else if (searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final result = searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: result['avtUrl'] != null
                              ? NetworkImage(result['avtUrl'])
                              : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                        ),
                        title: Text(result['name'] ?? 'Unknown'),
                        subtitle: Text(
                            result['nameFromEmail'] ?? 'No role available'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _addUserToParticipants(result);
                          },
                          child: const Text('Add'),
                        ),
                      );
                    },
                  ),
                )
              else
                Expanded(
                  child: _participants.isEmpty
                      ? const Center(
                          child: Text('No participants added yet.'),
                        )
                      : ListView.builder(
                          itemCount: _participants.length,
                          itemBuilder: (context, index) {
                            final participant = _participants[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: participant['photoUrl'] != null
                                    ? NetworkImage(participant['photoUrl'])
                                    : const AssetImage(
                                            'assets/default_avatar.png')
                                        as ImageProvider,
                              ),
                              title: Text(participant['name']),
                              subtitle: Text(participant['role'] ?? 'No role'),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeParticipant(
                                    participant['id'], index),
                              ),
                            );
                          },
                        ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: AddSpecialParticipantFormWithImage(
                  eventId: widget.eventId,
                  onParticipantAdded: _addUserToParticipants,
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddSpecialParticipantFormWithImage extends StatefulWidget {
  final Function(Map<String, dynamic>) onParticipantAdded;
  final int eventId;

  const AddSpecialParticipantFormWithImage({
    super.key,
    required this.onParticipantAdded,
    required this.eventId,
  });

  @override
  _AddSpecialParticipantFormWithImageState createState() =>
      _AddSpecialParticipantFormWithImageState();
}

class _AddSpecialParticipantFormWithImageState
    extends State<AddSpecialParticipantFormWithImage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedRole;
  File? _selectedImage;
  bool _isLoading = false;
  String _uploadedBase64Data = "";
  String? uploadedImageUrl;

  final List<String> _roles = ['Speaker', 'Special Guest'];

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files?.isEmpty ?? true) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final reader = html.FileReader();
      reader.readAsDataUrl(files![0]);

      reader.onLoadEnd.listen((e) {
        setState(() {
          _uploadedBase64Data = reader.result as String;
          uploadedImageUrl = _uploadedBase64Data;
          _isLoading = false;
        });
      });
    });
  }

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedImage = File(pickedFile.path);
  //     });
  //   }
  // }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final fileName =
          '${_nameController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final photoUrl = await uploadDocumentsToImageKitWebVersion(
          _uploadedBase64Data,
          "${widget.eventId}/special-participant",
          fileName);
      final participant = {
        'name': _nameController.text,
        'role': _selectedRole!,
        'description': _descriptionController.text,
        'photoUrl': photoUrl,
        'registration_Date': DateTime.now().toIso8601String(),
      };
      await addSpecialParticipant(
        eventId: widget.eventId,
        name: _nameController.text,
        role: _selectedRole!,
        description: _descriptionController.text,
        photoUrl: photoUrl,
      );
      widget.onParticipantAdded(participant);
      Navigator.of(context).pop();
    } catch (error) {
      LoggerService.logger.e(error);
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
          shrinkWrap: true,
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
            const SizedBox(height: 20),
            _selectedImage != null
                ? Column(
                    children: [
                      Image.file(
                        _selectedImage!,
                        height: 150,
                      ),
                      const SizedBox(height: 10),
                    ],
                  )
                : const SizedBox.shrink(),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
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
