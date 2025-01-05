import 'package:event_management/src/service/ticket_service.dart';
import 'package:flutter/material.dart';

class CancelledUsersPage extends StatefulWidget {
  final List<Map<String, dynamic>> cancelledUsers;
  final VoidCallback refreshData;

  const CancelledUsersPage({
    super.key,
    required this.cancelledUsers,
    required this.refreshData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CancelledUsersPageState createState() => _CancelledUsersPageState();
}

class _CancelledUsersPageState extends State<CancelledUsersPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.cancelledUsers.isEmpty) {
      return const Center(
        child: Text('No user to display'),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () async {
                  await updateCancelTicketStatus(
                      widget.cancelledUsers
                          .map((user) => user['uid'] as String)
                          .toList(),
                      "Accepted");
                  widget.refreshData(); // Làm mới dữ liệu sau khi cập nhật
                },
                child: const Text('Đồng ý tất cả'),
              ),
              TextButton(
                onPressed: () async {
                  await updateCancelTicketStatus(
                      widget.cancelledUsers
                          .map((user) => user['uid'] as String)
                          .toList(),
                      "Rejected");
                  widget.refreshData(); // Làm mới dữ liệu sau khi cập nhật
                },
                child: const Text('Từ chối tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cancelledUsers.length,
              itemBuilder: (context, index) {
                final user = widget.cancelledUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: user["avtUrl"] != null
                          ? NetworkImage(user["avtUrl"]!)
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
                        Text(
                          user["nameFromEmail"] ?? "???",
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "Reason: ",
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${user["reason"] ?? "No reason provided"}",
                              style: TextStyle(color: Colors.grey[600]),
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            _showImageDialog(context, user["link_image"]);
                          },
                          child: const Text('Xem ảnh'),
                        )
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () async {
                            await updateCancelTicketStatus(
                                [user["uid"] as String], "Accepted");
                            widget.refreshData(); // Làm mới dữ liệu sau khi cập nhật
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            await updateCancelTicketStatus(
                                [user["uid"] as String], "Rejected");
                            widget.refreshData(); // Làm mới dữ liệu sau khi cập nhật
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
