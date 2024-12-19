// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:event_management/src/service/user_service.dart';
import 'package:flutter/material.dart';

final TextEditingController _searchController = TextEditingController();

// ignore: must_be_immutable
class AddMembersPage extends StatefulWidget {
  String name = '';
  AddMembersPage({super.key, required this.name});

  @override
  _AddMembersPageState createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> selectedUsers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();
    if (query.isNotEmpty) {
      _performSearch(query);
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      final results = await searchUser(query);
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      print('Error searching users: $e');
      setState(() {
        searchResults = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addUserToList(Map<String, dynamic> user) {
    setState(() {
      selectedUsers.add(user);
    });
  }

  void _removeUserFromList(Map<String, dynamic> user) {
    setState(() {
      selectedUsers.removeWhere((item) => item['id'] == user['id']);
    });
  }

  void _onDone() {
    print("Selected Users: $selectedUsers");
    Navigator.of(context).pop(selectedUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add ${widget.name}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onDone, // Done button
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search members...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _performSearch(value);
                } else {
                  setState(() {
                    searchResults = [];
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),

            // Search Results
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (searchResults.isNotEmpty)
              Expanded(
                  child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final member = searchResults[index];
                  final isSelected =
                      selectedUsers.any((user) => user['id'] == member['id']);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: member['avtUrl'].isNotEmpty
                          ? NetworkImage(member['avtUrl'])
                          : const NetworkImage(
                              'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
                    ),
                    title: Text(member['name']),
                    subtitle: Text(member['role']),
                    trailing: IconButton(
                      icon: Icon(isSelected ? Icons.remove : Icons.add),
                      onPressed: () {
                        if (isSelected) {
                          _removeUserFromList(member); // Remove button
                        } else {
                          _addUserToList(member); // Add button
                        }
                      },
                    ),
                  );
                },
              ))
            else
              const Center(child: Text("No members found")),

            const SizedBox(height: 16.0),

            // Display selected users
            if (selectedUsers.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selected Users:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Column(
                    children: selectedUsers.map((user) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['avtUrl'].isNotEmpty
                              ? NetworkImage(user['avtUrl'])
                              : const NetworkImage(
                                  'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
                        ),
                        title: Text(user['name']),
                        subtitle: Text(user['role']),
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
