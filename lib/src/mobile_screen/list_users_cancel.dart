import 'package:event_management/src/mobile_screen/setting_feed_back_cancel_event.dart';
import 'package:flutter/material.dart';


// ignore: must_be_immutable
class CancelledUsersScreen extends StatelessWidget {
  // Danh sách người dùng đã hủy tham gia (mock data)
  final List<Map<String, String>> cancelledUsers = [
    {
      "name": "John Doe",
      "email": "john.doe@example.com",
      "reason": "No longer interested",
      "avatar": "https://randomuser.me/api/portraits/men/1.jpg"
    },
    {
      "name": "Jane Smith",
      "email": "jane.smith@example.com",
      "reason": "Scheduling conflict",
      "avatar": "https://randomuser.me/api/portraits/women/2.jpg"
    },
    {
      "name": "Michael Johnson",
      "email": "michael.johnson@example.com",
      "reason": "Personal reasons",
      "avatar": "https://randomuser.me/api/portraits/men/3.jpg"
    },
    {
      "name": "Emily Davis",
      "email": "emily.davis@example.com",
      "reason": "Found another event",
      "avatar": "https://randomuser.me/api/portraits/women/4.jpg"
    },
  ];

  String eventID;

  CancelledUsersScreen({super.key,required this.eventID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Cancelled Users'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  SettingCancelEvent(eventId: eventID,)),
              );
            },
          ),
        ],
      ),
      body: cancelledUsers.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: cancelledUsers.length,
              itemBuilder: (context, index) {
                final user = cancelledUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: user["avatar"] != null
                          ? NetworkImage(user["avatar"]!)
                          : const AssetImage("assets/default_avatar.png")
                              as ImageProvider, // Hình ảnh mặc định nếu không có avatar
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
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                'No cancelled users available.',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ),
    );
  }
}
