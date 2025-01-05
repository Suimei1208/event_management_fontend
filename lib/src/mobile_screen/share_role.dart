// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:event_management/src/service/user_service.dart';

class ShareRolePage extends StatefulWidget {
  const ShareRolePage({super.key});

  @override
  _ShareRolePageState createState() => _ShareRolePageState();
}

class _ShareRolePageState extends State<ShareRolePage> {
  List<Map<String, dynamic>> searchResults = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
    // Handle the user selection logic here.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User Selected: ${user['name']}')),
    );
    // You can navigate to another page or do other actions.
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
                            _selectUser(user);
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
        ],
      ),
    );
  }
}
