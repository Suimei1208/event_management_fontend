import 'package:flutter/material.dart';

class AlreadyCancelledUsersPage extends StatefulWidget {
  final List<Map<String, dynamic>> cancelledUsers;

  const AlreadyCancelledUsersPage({super.key, required this.cancelledUsers});

  @override
  // ignore: library_private_types_in_public_api
  _AlreadyCancelledUsersPageState createState() =>
      _AlreadyCancelledUsersPageState();
}

class _AlreadyCancelledUsersPageState extends State<AlreadyCancelledUsersPage> {
  @override
  Widget build(BuildContext context) {
    // Check if the list is not empty
    if (widget.cancelledUsers.isEmpty) {
      return const Center(
        child: Text('No user to display'),
      );
    }

    // Show the list if it's not empty
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: widget.cancelledUsers.length,
        itemBuilder: (context, index) {
          final user = widget.cancelledUsers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: user["avatar"] != null
                    ? NetworkImage(user["avatar"]!)
                    : const AssetImage("assets/default_avatar.png")
                        as ImageProvider,
              ),
              title: Text(
                user["name"] ?? "Unknown",
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user["email"] ?? "No email"),
                  const SizedBox(height: 4),
                  Text(
                    "Reason: ${user["reason"] ?? "No reason provided"}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: TextButton(
                onPressed: () {
                  // Hiển thị ảnh khi bấm nút
                  _showImageDialog(context, user["avatar"]);
                },
                child: const Text('Xem ảnh'),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageDialog(BuildContext context, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: imageUrl != null
              ? Image.network(imageUrl)
              : const Text('No image available'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
