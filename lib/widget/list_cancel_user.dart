import 'package:flutter/material.dart';

class CancelledUsersPage extends StatefulWidget {
  final List<Map<String, dynamic>> cancelledUsers;

  const CancelledUsersPage({super.key, required this.cancelledUsers});

  @override
  // ignore: library_private_types_in_public_api
  _CancelledUsersPageState createState() => _CancelledUsersPageState();
}

class _CancelledUsersPageState extends State<CancelledUsersPage> {
  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
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
                onPressed: () {
                  // Giữ nút để hiển thị text, không cần thêm logic
                },
                child: const Text('Đồng ý tất cả'),
              ),
              TextButton(
                onPressed: () {
                  // Giữ nút để hiển thị text, không cần thêm logic
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
                        // Text(
                        //   user["email"] ?? "No email",
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                        // const SizedBox(height: 4),
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
                          onPressed: () {
                            // Đồng ý user
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            // Từ chối user
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
