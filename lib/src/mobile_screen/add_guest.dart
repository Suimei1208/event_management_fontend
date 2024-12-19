// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:event_management/src/service/user_service.dart';
import 'package:flutter/material.dart';

final TextEditingController _searchController = TextEditingController();

class AddMembersPage extends StatefulWidget {
  const AddMembersPage({super.key});

  @override
  _AddMembersPageState createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Members"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: member['avtUrl'].isNotEmpty
                          ? NetworkImage(member['avtUrl'])
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                    ),
                    title: Text(member['name']),
                    subtitle: Text(member['role']),
                  );
                },
              ))
            else
              const Center(child: Text("No members found")),
          ],
        ),
      ),
    );
  }
}
